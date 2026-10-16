// App health + Android-level crash reports (16 Oct 2026): the server counts
// phones per build (X-App-Install), crashes per build (device_info.build_number)
// and now also gets crashes below Flutter (NativeCrashRecorder.kt).
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/app_update/install_id.dart';
import 'package:arobo_app/services/crash_report_service.dart';
import 'package:arobo_app/services/native_crash_reporter.dart';

void main() {
  group('InstallId', () {
    setUp(() => InstallId.current = null);

    test('random 24-hex code, created once and kept', () async {
      SharedPreferences.setMockInitialValues({});
      final first = await InstallId.load();
      expect(InstallId.isValid(first), isTrue);
      InstallId.current = null;
      expect(await InstallId.load(), first); // same code on the next launch
    });

    test('a bad stored value is replaced; codes differ between installs', () async {
      SharedPreferences.setMockInitialValues({'aorbo_install_id': 'not-a-code'});
      expect(InstallId.isValid(await InstallId.load()), isTrue);
      expect(InstallId.generate(Random(1)), isNot(InstallId.generate(Random(2))));
    });
  });

  test('every request carries the install code next to the version headers', () async {
    final options = RequestOptions(path: '/x');
    final interceptor = AppVersionHeadersInterceptor(
      info: () => AppVersionInfo.from(version: '1.0.0', buildNumber: '29', platform: 'android'),
      install: () => 'a1b2c3d4e5f60718293a4b5c',
    );
    interceptor.onRequest(options, RequestInterceptorHandler());
    expect(options.headers['X-App-Build'], '29');
    expect(options.headers['X-App-Install'], 'a1b2c3d4e5f60718293a4b5c');
  });

  test('crash reports name their build', () {
    final body = CrashReportService.payload(
      error: 'boom', fatal: true, sessionId: 's', os: 'android', appVersion: '1.0.0', buildNumber: '29', buildMode: 'release',
    );
    expect((body['device_info'] as Map)['build_number'], '29');
    final noBuild = CrashReportService.payload(error: 'boom', fatal: true, sessionId: 's', os: 'android', buildMode: 'release');
    expect((noBuild['device_info'] as Map).containsKey('build_number'), isFalse);
  });

  group('Android-level crash from the last run', () {
    const saved = '{"message":"java.lang.RuntimeException: Unable to get provider androidx.startup.InitializationProvider",'
        '"root_cause":"java.lang.RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase",'
        '"stack":"java.lang.RuntimeException: Unable to get provider\\n\\tat android.app.ActivityThread.installProvider(ActivityThread.java:8333)",'
        '"thread":"main","at":1792132000000}';

    test('is read, labelled as an Android crash, and sent', () async {
      Object? sentError;
      StackTrace? sentStack;
      await NativeCrashReporter.sendPending(take: () async => saved, send: (e, s) async { sentError = e; sentStack = s; });
      expect(sentError.toString(), startsWith('Android crash: java.lang.RuntimeException: Unable to get provider'));
      expect(sentError.toString(), contains('cause: java.lang.RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase'));
      expect(sentStack.toString(), contains('ActivityThread.installProvider'));
    });

    test('nothing saved / unreadable: nothing sent, never throws', () async {
      var sent = 0;
      for (final raw in [null, '', 'not json', '{"stack":"x"}', '[1,2]']) {
        await NativeCrashReporter.sendPending(take: () async => raw, send: (e, s) async => sent++);
      }
      expect(sent, 0);
      await NativeCrashReporter.sendPending(take: () async => throw Exception('channel gone'), send: (e, s) async => sent++);
      expect(sent, 0);
    });
  });

  test('the Android side is wired: application class, early install, channel', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:name=".AorboApplication"'));
    final app = File('android/app/src/main/kotlin/com/aorbotreks/app/AorboApplication.kt').readAsStringSync();
    expect(app, contains('override fun attachBaseContext'));
    expect(app, contains('NativeCrashRecorder.install(base)'));
    final recorder = File('android/app/src/main/kotlin/com/aorbotreks/app/NativeCrashRecorder.kt').readAsStringSync();
    expect(recorder, contains('previous.uncaughtException(thread, error)')); // Crashlytics / Android still run
    expect(File('android/app/src/main/kotlin/com/aorbotreks/app/MainActivity.kt').readAsStringSync(), contains('NativeCrashRecorder.channel('));
  });
}

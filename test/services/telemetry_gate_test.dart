// Only customer (release) builds report to the live server. 14 Oct 2026: an
// integration-test failure was filed as two "fatal app crashes" and e-mailed
// the owner.

import 'dart:io';

import 'package:arobo_app/services/crash_report_service.dart';
import 'package:arobo_app/services/telemetry_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(TelemetryGate.resetForTest);

  test('a test / developer run (debug build) never reports', () {
    expect(TelemetryGate.buildMode, 'debug');
    expect(TelemetryGate.allowed, isFalse);
    expect(CrashReportService.shouldSend, isFalse);
  });

  test('a release build reports, unless a test switched reporting off', () {
    TelemetryGate.buildModeOf = () => 'release';
    expect(TelemetryGate.allowed, isTrue);
    expect(CrashReportService.shouldSend, isTrue);
    TelemetryGate.enabled = false;
    expect(TelemetryGate.allowed, isFalse);
    expect(CrashReportService.shouldSend, isFalse);
  });

  test('a profile build does not report', () {
    TelemetryGate.buildModeOf = () => 'profile';
    expect(TelemetryGate.allowed, isFalse);
  });

  test('a crash report says which kind of build sent it', () {
    final body = CrashReportService.payload(
      error: StateError('boom'),
      fatal: true,
      sessionId: 's1',
      os: 'android',
      appVersion: '1.0.0',
      buildMode: 'release',
    );
    expect((body['device_info'] as Map)['build_mode'], 'release');
    expect(body['severity'], 'fatal');
  });

  // Guard: every report the app sends to the server goes through the gate,
  // so a new one can't quietly skip it.
  test('every app → server report path checks TelemetryGate', () {
    final report = RegExp(
      r"'(crash-report|analytics/events|device-security/report)'|sponsoredSlot(Impression|Click)\(",
    );
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.endsWith('network_url.dart')) continue;
      final src = f.readAsStringSync();
      if (report.hasMatch(src) && !src.contains('TelemetryGate.allowed') && !src.contains('shouldSend')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty, reason: 'check TelemetryGate.allowed before reporting');
  });
}

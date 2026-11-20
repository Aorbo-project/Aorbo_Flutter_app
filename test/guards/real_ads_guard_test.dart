// Real ads from 1.0.0+45 (20 Nov 2026): release builds use the real AdMob unit, debug builds and the
// team's test devices get test ads, iOS stays on test ids until its own ad unit exists, and the
// manifest carries the real App ID. The server sends the Google fallback only to build >= 45.
import 'dart:io';

import 'package:arobo_app/config/ad_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('real ads only outside debug; iOS never gets an empty unit; manifest App ID is the real one', () {
    final src = File('lib/config/ad_config.dart').readAsStringSync();
    expect(src, contains('static const bool useRealAds = !kDebugMode;'));
    expect(src, contains("useRealAds && _realNativeIos.isNotEmpty ? _realNativeIos : _testNativeIos"));
    expect(AdConfig.testDeviceIds, isNotEmpty);
    expect(File('android/app/src/main/AndroidManifest.xml').readAsStringSync(), contains('ca-app-pub-1409410183966075~2943255858'));
    final version = RegExp(r'^version: \d+\.\d+\.\d+\+(\d+)', multiLine: true).firstMatch(File('pubspec.yaml').readAsStringSync())!;
    expect(int.parse(version.group(1)!), greaterThanOrEqualTo(45), reason: 'the server gives the Google fallback to build >= 45 only');
  });
}

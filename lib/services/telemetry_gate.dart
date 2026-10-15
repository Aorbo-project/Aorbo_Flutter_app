import 'package:flutter/foundation.dart';

/// One rule for everything the app reports about itself to the live server:
/// crash reports, usage analytics, sponsored-ad impressions / clicks and
/// device-security reports.
///
/// Only customer builds (release — what the Play Store installs) report.
/// A developer's `flutter run`, `flutter test` and the integration test on a
/// real phone are debug builds, so their errors, taps and "debugger attached"
/// flags never become customer crash alerts, analytics, ad statistics or
/// security notices. (14 Oct 2026: an integration-test failure was filed as
/// two "fatal app crashes" and e-mailed the owner.) The same rule Crashlytics
/// already follows here (collection is off unless release).
class TelemetryGate {
  TelemetryGate._();

  /// Switched off by automated tests as an extra safeguard, whatever the
  /// build type.
  static bool enabled = true;

  /// 'release' | 'profile' | 'debug'. Overridable in tests.
  @visibleForTesting
  static String Function() buildModeOf = _platformBuildMode;

  static String _platformBuildMode() =>
      kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug');

  static String get buildMode => buildModeOf();

  /// Whether this run may report anything to the server.
  static bool get allowed => enabled && buildMode == 'release';

  @visibleForTesting
  static void resetForTest() {
    enabled = true;
    buildModeOf = _platformBuildMode;
  }
}

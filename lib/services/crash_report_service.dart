import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:arobo_app/app_update/app_version_info.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/security/pinned_http_client.dart';
import 'package:arobo_app/services/telemetry_gate.dart';
import 'package:arobo_app/utils/auth_utils.dart';

/// Sends every crash Firebase Crashlytics already sees into Aorbo's own
/// admin panel too (POST /api/v1/crash-report), so vendor/admin web crashes
/// and customer app crashes show up in ONE place (Admin > Crash Analytics)
/// instead of the mobile ones being invisible unless someone remembers to
/// separately open the Firebase console. Crashlytics stays as-is — this is
/// additive, never a replacement, and must never itself cause a crash or
/// block anything: same fire-and-forget contract as AnalyticsService.
class CrashReportService {
  CrashReportService._();
  static final CrashReportService instance = CrashReportService._();

  /// Only customer (release) builds report — see TelemetryGate.
  static bool get shouldSend => TelemetryGate.allowed;

  /// The report body. `device_info.build_mode` lets the server keep any
  /// non-release report out of the alerts even if one ever arrives.
  @visibleForTesting
  static Map<String, dynamic> payload({
    required Object error,
    StackTrace? stack,
    required bool fatal,
    String? screenName,
    required String sessionId,
    required String os,
    String? osVersion,
    String? deviceModel,
    String? appVersion,
    required String buildMode,
  }) =>
      {
        'error_message': error.toString(),
        'stack_trace': stack?.toString(),
        'severity': fatal ? 'fatal' : 'error',
        'screen_name': screenName ?? 'mobile_app',
        'session_id': sessionId,
        'device_info': {
          'os': os,
          // Backend stores this as device_info.version (was always null).
          'version': osVersion,
          'device_model': deviceModel,
          'app_version': appVersion,
          'build_mode': buildMode,
        },
      };

  /// One random id per app launch, so every crash from the same run can be
  /// grouped in Admin > Crash Analytics (it was always NULL before — a
  /// rebuild-loop's 1000+ reports were indistinguishable from 1000 sessions).
  /// Random, not derived from any user/device identifier.
  static final String _sessionId = () {
    final r = Random.secure();
    final rand = List.generate(8, (_) => r.nextInt(36).toRadixString(36)).join();
    return '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}-$rand';
  }();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: NetworkUrl.baseUrl, // .../api/v1/
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
    ),
  )..interceptors.add(AppVersionHeadersInterceptor());

  // Scan E5: this request carries the customer's access token, so it goes
  // through the same pinned TLS client as every other API call (it used to
  // use the phone's normal trust store, readable by an interception proxy).
  bool _pinned = false;
  Dio get _client {
    if (!_pinned) {
      PinnedHttp.apply(_dio);
      _pinned = true;
    }
    return _dio;
  }

  /// Rebuild the TLS layer (the remote pinning switch changed).
  void resetHttpClient() => PinnedHttp.apply(_dio);

  @visibleForTesting
  Dio get clientForTesting => _client;

  /// The screen on top when the crash happened (set from main.dart's
  /// routingCallback). Reports used to say only "mobile_app", so a layout
  /// overflow could not be traced to its screen.
  static String? currentScreen;

  /// The screen a report names: the caller's, else the one on top.
  @visibleForTesting
  static String? screenFor(String? explicit) =>
      (explicit != null && explicit.isNotEmpty) ? explicit : currentScreen;

  Future<void> report(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? screenName,
  }) async {
    if (!shouldSend) return;
    try {
      final appVersion = await AuthUtils.getAppVersion();
      final deviceModel = await AuthUtils.getDeviceModel();
      final osVersion = await AuthUtils.getOsVersion();

      await _client.post(
        'crash-report',
        data: payload(
          error: error,
          stack: stack,
          fatal: fatal,
          screenName: screenFor(screenName),
          sessionId: _sessionId,
          os: Platform.isIOS ? 'ios' : 'android',
          osVersion: osVersion,
          deviceModel: deviceModel,
          appVersion: appVersion,
          buildMode: TelemetryGate.buildMode,
        ),
        options: Options(
          headers: Repository.token.isNotEmpty
              ? {'Authorization': 'Bearer ${Repository.token}'}
              : null,
        ),
      );
    } catch (e) {
      // Best-effort only — this endpoint is a bonus admin-visibility mirror
      // of Crashlytics, never a dependency. Never let a reporting failure
      // become a second crash.
      if (kDebugMode) debugPrint('CrashReportService.report failed: $e');
    }
  }
}

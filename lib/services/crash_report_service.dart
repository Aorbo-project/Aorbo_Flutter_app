import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
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
  );

  Future<void> report(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? screenName,
  }) async {
    try {
      final appVersion = await AuthUtils.getAppVersion();
      final deviceModel = await AuthUtils.getDeviceModel();
      final osVersion = await AuthUtils.getOsVersion();

      await _dio.post(
        'crash-report',
        data: {
          'error_message': error.toString(),
          'stack_trace': stack?.toString(),
          'severity': fatal ? 'fatal' : 'error',
          'screen_name': screenName ?? 'mobile_app',
          'session_id': _sessionId,
          'device_info': {
            'os': Platform.isIOS ? 'ios' : 'android',
            // Backend stores this as device_info.version (was always null).
            'version': osVersion,
            'device_model': deviceModel,
            'app_version': appVersion,
          },
        },
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

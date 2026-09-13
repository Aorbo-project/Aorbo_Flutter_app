import 'dart:io';

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

      await _dio.post(
        'crash-report',
        data: {
          'error_message': error.toString(),
          'stack_trace': stack?.toString(),
          'severity': fatal ? 'fatal' : 'error',
          'screen_name': screenName ?? 'mobile_app',
          'device_info': {
            'os': Platform.isIOS ? 'ios' : 'android',
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

import 'package:dio/dio.dart';

/// Which failed API calls are worth a Crashlytics error report (17 Oct 2026).
///
/// Every refused call used to be reported except 400 / 409, so normal answers
/// — 401 "sign in again" on an expired session at app start, 429 "please wait
/// before another OTP", 403, 404 — became Crashlytics "issues" and alert
/// e-mails, burying real faults. Reported now: the server failing (5xx) and
/// failures nobody expects. Not reported: the server's own "no" (any 4xx),
/// and the phone being offline / slow (connection errors, timeouts, cancels).
/// A TLS pin mismatch is reported separately (device-security report).
bool shouldReportApiError(int? statusCode, DioExceptionType type) {
  if (statusCode != null) return statusCode >= 500;
  switch (type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
      return false;
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      return true;
  }
}

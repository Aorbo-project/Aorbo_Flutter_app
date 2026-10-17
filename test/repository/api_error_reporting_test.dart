// Crashlytics alert e-mails were the app's own normal "no" answers (17 Oct 2026):
// 401 on an expired session at start (6 events), 429 "please wait" (3 events).
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/repository/api_error_reporting.dart';

void main() {
  test('the server failing is reported', () {
    for (final code in [500, 502, 503, 504]) {
      expect(shouldReportApiError(code, DioExceptionType.badResponse), isTrue, reason: '$code');
    }
  });

  test("the server's own answers are not errors", () {
    for (final code in [400, 401, 403, 404, 409, 410, 422, 426, 429]) {
      expect(shouldReportApiError(code, DioExceptionType.badResponse), isFalse, reason: '$code');
    }
  });

  test('offline / slow network is not an app error; an unexpected failure is', () {
    for (final t in [
      DioExceptionType.connectionTimeout, DioExceptionType.sendTimeout, DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError, DioExceptionType.cancel, DioExceptionType.badCertificate,
    ]) {
      expect(shouldReportApiError(null, t), isFalse, reason: '$t');
    }
    expect(shouldReportApiError(null, DioExceptionType.unknown), isTrue);
  });
}

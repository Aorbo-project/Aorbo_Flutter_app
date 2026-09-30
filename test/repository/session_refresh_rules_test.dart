import 'package:arobo_app/repository/repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _http(int status) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: status),
      type: DioExceptionType.badResponse,
    );

DioException _network(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(path: '/x'), type: type);

void main() {
  group('refreshOutcomeForError — only a rejected refresh token signs the user out', () {
    test('the server rejecting the refresh token ends the session', () {
      for (final status in [400, 401, 403]) {
        expect(refreshOutcomeForError(_http(status)), RefreshOutcome.sessionOver, reason: '$status');
      }
    });

    test('no connection, timeouts, rate limits and server errors keep the session', () {
      for (final e in [
        _network(DioExceptionType.connectionError),
        _network(DioExceptionType.connectionTimeout),
        _network(DioExceptionType.receiveTimeout),
        _http(429),
        _http(500),
        _http(502),
        _http(503),
      ]) {
        expect(refreshOutcomeForError(e), RefreshOutcome.transientFailure, reason: '$e');
      }
      expect(refreshOutcomeForError(StateError('boom')), RefreshOutcome.transientFailure);
    });
  });

  group('replayFailureEndsSession — after a successful refresh', () {
    test('only a 401 on the replayed request ends the session', () {
      expect(replayFailureEndsSession(_http(401)), isTrue);
    });

    test("a business error or a network blip is the request's own result", () {
      for (final e in [_http(400), _http(404), _http(409), _http(500), _network(DioExceptionType.receiveTimeout)]) {
        expect(replayFailureEndsSession(e), isFalse, reason: '$e');
      }
    });
  });

  group('holdUnsignedRefresh — never send an unsigned refresh for a device-bound login', () {
    test('bound login without a signature is held', () {
      expect(holdUnsignedRefresh(bound: true, signature: null), isTrue);
    });

    test('signed, unbound, or pre-flag logins go ahead', () {
      expect(holdUnsignedRefresh(bound: true, signature: 'sig'), isFalse);
      expect(holdUnsignedRefresh(bound: false, signature: null), isFalse);
      expect(holdUnsignedRefresh(bound: null, signature: null), isFalse);
    });
  });

  test('RateLimitException carries whether the OTP already sent is still valid', () {
    expect(const RateLimitException('wait', 40, otpActive: true).otpActive, isTrue);
    expect(const RateLimitException('wait', 40).otpActive, isFalse);
  });
}

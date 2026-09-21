import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';

/// Fast-fail + automatic retry for idempotent GET requests.
///
/// Why this exists: the API sits behind a CDN whose route for an Indian user's
/// connection sometimes flips to a far-away or stalled edge. When that happens a
/// single request can hang for many seconds, and with the old 40 s timeouts the
/// app looked frozen. A *fresh* connection a moment later usually lands on a
/// good route, so it is better to give up quickly and try again.
///
/// Scope (deliberately narrow):
///  * GET only — never POST/PUT/PATCH/DELETE (payments, bookings, uploads must
///    never be replayed automatically).
///  * Not for downloads (`ResponseType.stream` / `bytes`).
///  * Opt out per request with `extra: {GetRetryInterceptor.longTimeoutKey: true}`.
///  * Only transport-level failures and gateway errors are retried; 4xx (incl.
///    401 → handled by the token-refresh interceptor) are never retried here.
class GetRetryInterceptor extends Interceptor {
  GetRetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.connectTimeout = const Duration(seconds: 5),
    this.receiveTimeout = const Duration(seconds: 8),
    this.backoff = const [
      Duration(milliseconds: 400),
      Duration(milliseconds: 1200),
    ],
  });

  static const String retryCountKey = '__net_retry';
  static const String longTimeoutKey = 'long_timeout';

  final Dio _dio;
  final int maxRetries;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final List<Duration> backoff;

  bool _applies(RequestOptions o) =>
      o.method.toUpperCase() == 'GET' &&
      o.responseType != ResponseType.stream &&
      o.responseType != ResponseType.bytes &&
      o.extra[longTimeoutKey] != true;

  /// Transport failures and gateway/edge errors that a fresh attempt can fix.
  static bool isRetryable(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        // 502/503/504 = gateway; 520–524 = Cloudflare edge↔origin errors.
        return code == 502 || code == 503 || code == 504 ||
            (code >= 520 && code <= 524);
      case DioExceptionType.unknown:
        final inner = e.error;
        return inner is SocketException ||
            inner is HandshakeException ||
            inner is HttpException;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return false;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_applies(options)) {
      options.connectTimeout = connectTimeout;
      options.receiveTimeout = receiveTimeout;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final o = err.requestOptions;
    final attempt = (o.extra[retryCountKey] as int?) ?? 0;
    if (!_applies(o) || attempt >= maxRetries || !isRetryable(err)) {
      return handler.next(err);
    }

    o.extra[retryCountKey] = attempt + 1;
    if (backoff.isNotEmpty) {
      await Future<void>.delayed(backoff[math.min(attempt, backoff.length - 1)]);
    }
    try {
      // The nested call carries the incremented counter, so any further
      // retries are bounded by [maxRetries] in total.
      final response = await _dio.fetch<dynamic>(o);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

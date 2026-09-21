import 'dart:typed_data';

import 'package:arobo_app/repository/get_retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scripted network: each entry is 'timeout' or an HTTP status code. The last
/// entry repeats. Records every request so tests can count attempts.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);
  final List<Object> script;
  final List<RequestOptions> seen = [];

  int get calls => seen.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final step = script[calls < script.length ? calls : script.length - 1];
    seen.add(options);
    if (step == 'timeout') {
      throw DioException.connectionTimeout(
        timeout: options.connectTimeout ?? const Duration(seconds: 1),
        requestOptions: options,
      );
    }
    return ResponseBody.fromString(
      '{"ok":true}',
      step as int,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(List<Object> script, {int maxRetries = 2}) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://example.test',
    connectTimeout: const Duration(seconds: 40),
    receiveTimeout: const Duration(seconds: 40),
  ));
  dio.httpClientAdapter = _ScriptedAdapter(script);
  dio.interceptors.add(GetRetryInterceptor(
    dio,
    maxRetries: maxRetries,
    backoff: const [Duration.zero],
  ));
  return dio;
}

_ScriptedAdapter _adapter(Dio d) => d.httpClientAdapter as _ScriptedAdapter;

void main() {
  group('GetRetryInterceptor', () {
    test('GET: a timeout then success is recovered transparently (2 attempts)',
        () async {
      final dio = _dioWith(['timeout', 200]);
      final res = await dio.get('/api/v1/treks');
      expect(res.statusCode, 200);
      expect(_adapter(dio).calls, 2);
    });

    test('GET: gateway errors 503,504 then success (3 attempts = 1 + 2 retries)',
        () async {
      final dio = _dioWith([503, 504, 200]);
      final res = await dio.get('/x');
      expect(res.statusCode, 200);
      expect(_adapter(dio).calls, 3);
    });

    test('GET: Cloudflare 522 is retried', () async {
      final dio = _dioWith([522, 200]);
      final res = await dio.get('/x');
      expect(res.statusCode, 200);
      expect(_adapter(dio).calls, 2);
    });

    test('GET: retries are bounded — persistent failure surfaces after 1 + 2 calls',
        () async {
      final dio = _dioWith(['timeout']);
      await expectLater(
        dio.get('/x'),
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.connectionTimeout)),
      );
      expect(_adapter(dio).calls, 3);
    });

    test('GET: 4xx is never retried (401/404/400)', () async {
      for (final code in [400, 401, 404, 429]) {
        final dio = _dioWith([code, 200]);
        await expectLater(dio.get('/x'), throwsA(isA<DioException>()));
        expect(_adapter(dio).calls, 1, reason: 'status $code must not retry');
      }
    });

    test('POST is never retried, even on timeout (payments must not replay)',
        () async {
      final dio = _dioWith(['timeout', 200]);
      await expectLater(
        dio.post('/api/v1/bookings/create-order', data: {'a': 1}),
        throwsA(isA<DioException>()),
      );
      expect(_adapter(dio).calls, 1);
    });

    test('opt-out via long_timeout: no retry and timeouts left untouched',
        () async {
      final dio = _dioWith(['timeout', 200]);
      await expectLater(
        dio.get('/big',
            options: Options(extra: {GetRetryInterceptor.longTimeoutKey: true})),
        throwsA(isA<DioException>()),
      );
      final adapter = _adapter(dio);
      expect(adapter.calls, 1);
      expect(adapter.seen.first.connectTimeout, const Duration(seconds: 40));
      expect(adapter.seen.first.receiveTimeout, const Duration(seconds: 40));
    });

    test('downloads (bytes/stream) are excluded', () async {
      final dio = _dioWith(['timeout', 200]);
      await expectLater(
        dio.get('/invoice.pdf',
            options: Options(responseType: ResponseType.bytes)),
        throwsA(isA<DioException>()),
      );
      expect(_adapter(dio).calls, 1);
    });

    test('GET gets fast-fail timeouts (5s connect / 8s receive); POST keeps base',
        () async {
      final dio = _dioWith([200]);
      await dio.get('/x');
      await dio.post('/y', data: {});
      final seen = _adapter(dio).seen;
      expect(seen[0].connectTimeout, const Duration(seconds: 5));
      expect(seen[0].receiveTimeout, const Duration(seconds: 8));
      expect(seen[1].connectTimeout, const Duration(seconds: 40));
      expect(seen[1].receiveTimeout, const Duration(seconds: 40));
    });

    test('isRetryable: cancel and bad certificate are not retryable', () {
      final ro = RequestOptions(path: '/x');
      expect(
        GetRetryInterceptor.isRetryable(
            DioException(requestOptions: ro, type: DioExceptionType.cancel)),
        isFalse,
      );
      expect(
        GetRetryInterceptor.isRetryable(DioException(
            requestOptions: ro, type: DioExceptionType.badCertificate)),
        isFalse,
      );
    });
  });
}

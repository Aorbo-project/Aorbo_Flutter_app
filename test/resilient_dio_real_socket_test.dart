import 'dart:convert';
import 'dart:io';

import 'package:arobo_app/repository/get_retry_interceptor.dart';
import 'package:arobo_app/repository/hedging_http_client_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end check with REAL sockets and the REAL dart:io Dio adapter (no
/// fakes): a local server whose first request stalls, second answers at once.
/// Proves the whole stack (retry interceptor + hedging adapter + IO adapter +
/// request cancellation) behaves as designed — the unit tests only cover the
/// pieces against a fake adapter.
void main() {
  late HttpServer server;
  late List<String> hits; // "<n> <method> <path>" in arrival order

  // stallFirst: the first N arrivals are held for [stallFor] before answering.
  var stallFirst = 0;
  var stallFor = const Duration(seconds: 3);
  var arrivals = 0;

  setUp(() async {
    hits = [];
    arrivals = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest req) async {
      final n = ++arrivals;
      hits.add('$n ${req.method} ${req.uri.path}');
      // A stalled arrival is simply answered late; if the client already gave up
      // (hedge loser cancelled) the write fails and is ignored.
      if (n <= stallFirst) await Future<void>.delayed(stallFor);
      try {
        req.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'ok': true, 'arrival': n}));
        await req.response.close();
      } catch (_) {/* client disconnected */}
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  Dio buildDio({Duration hedgeAfter = const Duration(milliseconds: 300)}) {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:${server.port}',
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    ));
    dio.interceptors.add(GetRetryInterceptor(dio));
    dio.httpClientAdapter =
        HedgingHttpClientAdapter(dio.httpClientAdapter, hedgeAfter: hedgeAfter);
    return dio;
  }

  test('REAL sockets: stalled first GET is rescued by the hedge in ~hedge time',
      () async {
    stallFirst = 1; // first arrival stalls for 3 s, the next one answers at once
    stallFor = const Duration(seconds: 3);
    final dio = buildDio();
    final sw = Stopwatch()..start();
    final res = await dio.get('/api/v1/states');
    sw.stop();

    expect(res.statusCode, 200);
    expect((res.data as Map)['arrival'], 2,
        reason: 'the 2nd (hedged) request is the one that answered');
    expect(sw.elapsed, lessThan(const Duration(seconds: 2)),
        reason: 'must not wait out the 3 s stall (took ${sw.elapsed})');
    expect(hits.length, 2, reason: 'exactly one duplicate, not a storm: $hits');
  });

  test('REAL sockets: healthy GET sends exactly ONE request', () async {
    stallFirst = 0;
    final dio = buildDio();
    final res = await dio.get('/api/v1/states');
    expect(res.statusCode, 200);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    expect(hits.length, 1, reason: '$hits');
  });

  test('REAL sockets: POST is never duplicated even when slow', () async {
    stallFirst = 1;
    stallFor = const Duration(milliseconds: 900); // slower than the 300 ms hedge
    final dio = buildDio();
    final res = await dio.post('/api/v1/bookings/create-order', data: {'a': 1});
    expect(res.statusCode, 200);
    expect(hits.length, 1, reason: 'a payment POST must go out exactly once: $hits');
    expect(hits.first.contains('POST'), isTrue);
  });
}

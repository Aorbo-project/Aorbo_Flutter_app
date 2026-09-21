import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:arobo_app/repository/get_retry_interceptor.dart';
import 'package:arobo_app/repository/hedging_http_client_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// One scripted attempt: wait [delay], then answer with [outcome]
/// (an HTTP status code, or 'timeout' to fail). The last step repeats.
class _Step {
  const _Step(this.delay, this.outcome);
  final Duration delay;
  final Object outcome;
}

class _FakeInner implements HttpClientAdapter {
  _FakeInner(this.steps);
  final List<_Step> steps;
  int calls = 0;
  final List<bool> cancelled = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final idx = calls++;
    cancelled.add(false);
    final step = steps[math.min(idx, steps.length - 1)];
    final abort = Completer<void>();
    cancelFuture?.then((_) {
      cancelled[idx] = true;
      if (!abort.isCompleted) abort.complete();
    });
    await Future.any([Future<void>.delayed(step.delay), abort.future]);
    if (cancelled[idx]) {
      throw DioException.requestCancelled(
          requestOptions: options, reason: 'cancelled');
    }
    if (step.outcome == 'timeout') {
      throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: options,
      );
    }
    return ResponseBody.fromString(
      '{"attempt":$idx}',
      step.outcome as int,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _fast = Duration(milliseconds: 10);
const _slow = Duration(milliseconds: 600);
const _hedge = Duration(milliseconds: 60);

final _inners = Expando<_FakeInner>();

Dio _dioWith(List<_Step> steps) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  final fake = _FakeInner(steps);
  _inners[dio] = fake;
  dio.httpClientAdapter = HedgingHttpClientAdapter(fake, hedgeAfter: _hedge);
  return dio;
}

_FakeInner _inner(Dio d) => _inners[d]!;

void main() {
  group('HedgingHttpClientAdapter', () {
    test('stalled first attempt: the duplicate wins and the loser is cancelled',
        () async {
      final dio = _dioWith([_Step(_slow, 200), _Step(_fast, 200)]);
      final sw = Stopwatch()..start();
      final res = await dio.get('/x');
      sw.stop();
      expect(res.data['attempt'], 1, reason: 'the hedge (2nd attempt) answered');
      expect(sw.elapsed, lessThan(const Duration(milliseconds: 400)),
          reason: 'must not wait for the slow first attempt');
      final inner = _inner(dio);
      expect(inner.calls, 2);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(inner.cancelled[0], isTrue, reason: 'loser must be cancelled');
    });

    test('fast first attempt: no duplicate is ever sent', () async {
      final dio = _dioWith([_Step(_fast, 200)]);
      final res = await dio.get('/x');
      expect(res.data['attempt'], 0);
      await Future<void>.delayed(_hedge * 2); // past the hedge timer
      expect(_inner(dio).calls, 1);
    });

    test('first attempt still wins if it answers after the hedge but before it',
        () async {
      // hedge fires at 60 ms; first answers at 90 ms; second would take 500 ms.
      final dio = _dioWith([
        const _Step(Duration(milliseconds: 90), 200),
        const _Step(Duration(milliseconds: 500), 200),
      ]);
      final res = await dio.get('/x');
      expect(res.data['attempt'], 0);
      expect(_inner(dio).calls, 2);
    });

    test('first attempt FAILS before the hedge: error goes up at once, no duplicate',
        () async {
      final dio = _dioWith([_Step(_fast, 'timeout'), _Step(_fast, 200)]);
      await expectLater(dio.get('/x'), throwsA(isA<DioException>()));
      await Future<void>.delayed(_hedge * 2);
      expect(_inner(dio).calls, 1,
          reason: 'retrying failures is the retry interceptor\'s job');
    });

    test('both attempts fail: surfaces an error (not a hang)', () async {
      final dio = _dioWith([
        const _Step(Duration(milliseconds: 150), 'timeout'),
        const _Step(Duration(milliseconds: 100), 'timeout'),
      ]);
      await expectLater(dio.get('/x'), throwsA(isA<DioException>()));
      expect(_inner(dio).calls, 2);
    });

    test('first stalls then fails, hedge succeeds → success', () async {
      final dio = _dioWith([
        const _Step(Duration(milliseconds: 200), 'timeout'),
        const _Step(Duration(milliseconds: 20), 200),
      ]);
      final res = await dio.get('/x');
      expect(res.statusCode, 200);
      expect(res.data['attempt'], 1);
    });

    test('POST is never hedged (payments must not be duplicated)', () async {
      final dio = _dioWith([_Step(_slow, 200), _Step(_fast, 200)]);
      final res = await dio.post('/pay', data: {'a': 1});
      expect(res.data['attempt'], 0);
      expect(_inner(dio).calls, 1);
    });

    test('downloads and explicit opt-outs are not hedged', () async {
      for (final opts in [
        Options(responseType: ResponseType.bytes),
        Options(extra: {HedgingHttpClientAdapter.noHedgeKey: true}),
        Options(extra: {GetRetryInterceptor.longTimeoutKey: true}),
      ]) {
        final dio = _dioWith([_Step(_slow, 200), _Step(_fast, 200)]);
        await dio.get('/big', options: opts);
        expect(_inner(dio).calls, 1);
      }
    });

    test('the request is only hedged ONCE (max 2 attempts in total)', () async {
      final dio = _dioWith([
        const _Step(Duration(milliseconds: 400), 200),
        const _Step(Duration(milliseconds: 400), 200),
      ]);
      await dio.get('/x');
      expect(_inner(dio).calls, 2);
    });
  });
}

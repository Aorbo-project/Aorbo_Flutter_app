import 'dart:async';
import 'dart:typed_data';

import 'package:arobo_app/repository/get_retry_interceptor.dart';
import 'package:dio/dio.dart';

/// Request hedging for idempotent GETs ("The Tail at Scale", Google).
///
/// If a GET has not produced response headers after [hedgeAfter], send ONE
/// duplicate on a fresh connection and use whichever answers first; the loser
/// is cancelled. Instead of waiting for a timeout to fire and then retrying
/// (many seconds), a stalled route costs only ~[hedgeAfter] extra — the same
/// idea browsers use for Happy Eyeballs, applied to request latency.
///
/// Sits at the transport layer, so interceptors above it (auth, logging,
/// token refresh, [GetRetryInterceptor]) still see exactly one request and one
/// response.
///
/// Scope mirrors [GetRetryInterceptor]: GET only, no body, no bytes/stream
/// downloads, opt out with `extra: {HedgingHttpClientAdapter.noHedgeKey: true}`
/// (or `GetRetryInterceptor.longTimeoutKey`). If the first attempt FAILS before
/// the hedge fires the error is passed up immediately — retrying failures is
/// the retry interceptor's job.
class HedgingHttpClientAdapter implements HttpClientAdapter {
  HedgingHttpClientAdapter(
    this._inner, {
    this.hedgeAfter = const Duration(seconds: 2),
  });

  static const String noHedgeKey = 'no_hedge';

  final HttpClientAdapter _inner;
  final Duration hedgeAfter;

  bool _eligible(RequestOptions o, Stream<Uint8List>? body) =>
      o.method.toUpperCase() == 'GET' &&
      body == null &&
      o.data == null &&
      o.responseType != ResponseType.stream &&
      o.responseType != ResponseType.bytes &&
      o.extra[noHedgeKey] != true &&
      o.extra[GetRetryInterceptor.longTimeoutKey] != true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (!_eligible(options, requestStream)) {
      return _inner.fetch(options, requestStream, cancelFuture);
    }

    final result = Completer<ResponseBody>();
    final cancels = <Completer<void>>[];
    Timer? hedgeTimer;
    var launched = 0;
    var failed = 0;

    void abortAllExcept(Completer<void>? keep) {
      for (final c in cancels) {
        if (!identical(c, keep) && !c.isCompleted) c.complete();
      }
    }

    void launch() {
      final cancel = Completer<void>();
      cancels.add(cancel);
      launched++;
      _inner.fetch(options, null, cancel.future).then(
        (body) {
          if (result.isCompleted) {
            // A loser that still produced a response: release its connection.
            body.stream.listen(null, onError: (Object _) {}).cancel();
            return;
          }
          hedgeTimer?.cancel();
          result.complete(body);
          abortAllExcept(cancel);
        },
        onError: (Object e, StackTrace st) {
          failed++;
          if (result.isCompleted) return;
          // Fail only once no launched attempt can still succeed.
          if (failed >= launched) {
            hedgeTimer?.cancel();
            result.completeError(e, st);
          }
        },
      );
    }

    cancelFuture?.then((_) {
      hedgeTimer?.cancel();
      abortAllExcept(null);
    });

    launch();
    hedgeTimer = Timer(hedgeAfter, () {
      if (!result.isCompleted && launched == 1) launch();
    });
    return result.future;
  }

  @override
  void close({bool force = false}) => _inner.close(force: force);
}

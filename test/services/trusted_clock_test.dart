// Scan D3: the network clock behind the date pickers must never hang.

import 'dart:async';

import 'package:arobo_app/services/trusted_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('an NTP lookup that never answers still completes (bounded) with device time', (tester) async {
    var calls = 0;
    final clock = TrustedClock(fetchOffset: (_) {
      calls++;
      return Completer<Duration>().future; // UDP reply never arrives
    });

    DateTime? result;
    clock.sync().then((t) => result = t);
    await tester.pump(const Duration(seconds: 1));
    expect(result, isNull, reason: 'still within the 2 s budget');

    await tester.pump(const Duration(seconds: 3));
    expect(result, isNotNull, reason: 'gave up after timeout + 1 s');
    expect(clock.isSynced, isFalse);
    expect(result!.difference(DateTime.now()).inSeconds.abs(), lessThan(5));

    // Not retried straight away (a UDP-blocking network would just hang again).
    await clock.sync();
    expect(calls, 1);
  });

  test('a working lookup applies the offset to now()', () async {
    final clock = TrustedClock(fetchOffset: (_) async => const Duration(minutes: 7));
    expect(clock.now().difference(DateTime.now()).inMinutes.abs(), 0, reason: 'device time before sync');
    final t = await clock.sync();
    expect(clock.isSynced, isTrue);
    expect(t.difference(DateTime.now()).inMinutes, inInclusiveRange(6, 7));
    expect(clock.now().difference(DateTime.now()).inMinutes, inInclusiveRange(6, 7));
  });

  test('one shared lookup for concurrent callers, none after success', () async {
    var calls = 0;
    final gate = Completer<Duration>();
    final clock = TrustedClock(fetchOffset: (_) {
      calls++;
      return gate.future;
    });
    final a = clock.sync();
    final b = clock.sync();
    gate.complete(Duration.zero);
    await Future.wait([a, b]);
    await clock.sync();
    expect(calls, 1);
  });

  test('a lookup that throws falls back to device time, never throws', () async {
    final clock = TrustedClock(fetchOffset: (_) async => throw const SocketLikeError());
    final t = await clock.sync();
    expect(clock.isSynced, isFalse);
    expect(t.difference(DateTime.now()).inSeconds.abs(), lessThan(5));
  });
}

class SocketLikeError implements Exception {
  const SocketLikeError();
}

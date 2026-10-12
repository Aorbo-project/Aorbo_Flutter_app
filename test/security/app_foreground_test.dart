// 2026-10-12: after a settled payment, a UPI app (PhonePe) stayed as an
// invisible window over the booking screen and took every tap. Once the
// server says paid/refunded, the app asks Android to close what sits above
// it in its own task, retrying until the app is really in front.

import 'package:arobo_app/security/app_foreground.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int asks;

  setUp(() {
    AppForeground.resetForTest();
    asks = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppForeground.channel, (call) async {
      if (call.method == 'reclaimForeground') asks++;
      return true;
    });
  });

  tearDown(() {
    AppForeground.resetForTest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppForeground.channel, null);
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('app already in front: asks nothing, no retry', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    AppForeground.reclaimAfterPayment();
    await tester.pump(const Duration(seconds: 10));
    expect(asks, 0);
    expect(AppForeground.isRetrying, isFalse);
  });

  testWidgets('another app on top: asks at once, again every 2 s, stops when the app is back in front', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    AppForeground.reclaimAfterPayment();
    await tester.pump();
    expect(asks, 1);

    // Android refused (screen off): keeps asking.
    await tester.pump(AppForeground.retryEvery);
    await tester.pump(AppForeground.retryEvery);
    expect(asks, 3);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(AppForeground.retryEvery);
    await tester.pump(const Duration(seconds: 10));
    expect(asks, 3, reason: 'in front again - no more asks');
    expect(AppForeground.isRetrying, isFalse);
  });

  testWidgets('never in front: gives up after a minute', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    AppForeground.reclaimAfterPayment();
    await tester.pump(AppForeground.giveUpAfter + const Duration(seconds: 10));
    expect(AppForeground.isRetrying, isFalse);
    final atGiveUp = asks;
    expect(atGiveUp, 1 + AppForeground.giveUpAfter.inSeconds ~/ AppForeground.retryEvery.inSeconds);
    await tester.pump(const Duration(seconds: 30));
    expect(asks, atGiveUp);
  });

  testWidgets('without the native side (iOS / old build) it never throws', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppForeground.channel, null);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    AppForeground.reclaimAfterPayment();
    await tester.pump(const Duration(seconds: 5));
    AppForeground.resetForTest();
  });
}

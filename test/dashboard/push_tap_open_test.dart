// Scan E1 (widget level): the signed-in dashboard opens a parked
// notification tap — one waiting from a cold start, and one that arrives
// while the dashboard is already up.

import 'package:arobo_app/screens/dashboard_main.dart';
import 'package:arobo_app/services/push_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../responsive/screen_responsive_harness.dart';

Widget _app() => Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        initialRoute: '/dashboard',
        getPages: [
          GetPage(name: '/dashboard', page: () => const DashboardMain()),
          GetPage(
            name: '/my-bookings',
            page: () => Scaffold(body: Text('MY BOOKINGS ${Get.arguments}')),
          ),
          GetPage(
            name: '/coupon-code',
            page: () => const Scaffold(body: Text('COUPONS')),
          ),
        ],
      ),
    );

Future<void> _withoutOverflowNoise(Future<void> Function() body) async {
  // The test font is wider than real fonts; overflow is covered by
  // test/responsive, not here.
  final previous = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    previous?.call(d);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
}

void main() {
  setUp(installScreenTestEnv);
  tearDown(() {
    PendingPush.instance.take();
    teardownScreenTestEnv();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('cold start: a tap parked before the dashboard existed opens My Bookings for that booking', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await _withoutOverflowNoise(() async {
      PendingPush.instance.save({'event': 'REFUND_ISSUED', 'bookingId': '42'}, signedIn: true);
      await tester.pumpWidget(_app());
      await settle(tester);

      expect(find.text('MY BOOKINGS {booking_id: 42}'), findsOneWidget);
      expect(PendingPush.instance.tapped.value, isNull, reason: 'opened once');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  });

  testWidgets('app open: a tap that arrives later opens its screen', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await _withoutOverflowNoise(() async {
      await tester.pumpWidget(_app());
      await settle(tester);
      expect(find.text('COUPONS'), findsNothing);

      PendingPush.instance.save({'event': 'COUPON_EXPIRING'}, signedIn: true);
      await settle(tester);

      expect(find.text('COUPONS'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

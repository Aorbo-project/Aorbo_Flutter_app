// Scan E6: a shared trek link or a notification tap that arrives while the
// customer is in the booking flow must not open on top of it (the trek
// link rewrote the shared TrekController the booking reads). It waits and
// opens once Home is the top screen again.

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/giveaway/referral_links.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/routes/app_route_observer.dart';
import 'package:arobo_app/screens/dashboard_main.dart';
import 'package:arobo_app/services/push_router.dart';
import 'package:arobo_app/share/trek_link.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../responsive/screen_responsive_harness.dart';

void main() {
  late int resolveCalls;

  setUp(() async {
    await installScreenTestEnv();
    resolveCalls = 0;
    Repository().dio.interceptors.insert(
      0,
      dio.InterceptorsWrapper(onRequest: (o, h) {
        if (o.path.contains('share/treks/')) {
          resolveCalls++;
          // The trek is gone: the opener just says so (no trek screen).
          return h.resolve(dio.Response(requestOptions: o, statusCode: 200, data: {'success': false}));
        }
        h.next(o);
      }),
    );
  });

  tearDown(() {
    PendingPush.instance.take();
    ReferralLinkCapture.instance.openTrekRequested.value = null;
    teardownScreenTestEnv();
  });

  testWidgets('during the booking flow a push tap and a trek link wait; back on Home they open', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final previous = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('overflowed')) return;
      previous?.call(d);
    };
    try {
      Future<void> settle() async {
        for (var i = 0; i < 8; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          navigatorObservers: [appRouteObserver],
          initialRoute: '/dashboard',
          getPages: [
            GetPage(name: '/dashboard', page: () => const DashboardMain()),
            GetPage(name: '/booking', page: () => const Scaffold(body: Text('TRAVELLER INFO'))),
            GetPage(name: '/my-bookings', page: () => Scaffold(body: Text('MY BOOKINGS ${Get.arguments}'))),
          ],
        ),
      ));
      await settle();
      final trekC = Get.find<TrekController>();
      trekC.trekDetailId.value = 11; // the trek being booked

      Get.toNamed('/booking');
      await settle();
      expect(find.text('TRAVELLER INFO'), findsOneWidget);

      PendingPush.instance.save({'event': 'REFUND_ISSUED', 'bookingId': '42'}, signedIn: true);
      ReferralLinkCapture.instance.openTrekRequested.value = const TrekLink('Ab3dEf7h');
      await settle();

      expect(find.text('TRAVELLER INFO'), findsOneWidget, reason: 'nothing opened over the booking');
      expect(find.textContaining('MY BOOKINGS'), findsNothing);
      expect(resolveCalls, 0, reason: 'the trek link was not opened');
      expect(trekC.trekDetailId.value, 11, reason: 'the booking still points at its trek');
      expect(PendingPush.instance.tapped.value, isNotNull, reason: 'the tap is kept');

      Get.back();
      await settle();

      expect(resolveCalls, 1, reason: 'the trek link opens once back on Home');
      expect(find.text('MY BOOKINGS {booking_id: 42}'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    } finally {
      FlutterError.onError = previous;
    }
  });
}

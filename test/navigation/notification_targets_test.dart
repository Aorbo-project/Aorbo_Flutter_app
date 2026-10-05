// Scan E11: notification taps and dead buttons.
// - A booking / refund notification opened My Bookings and ignored the
//   booking_id; the booking itself must open.
// - A tap in the in-app notification list only marked it read.
// - "Rate us" / "Become Partner" / "Claims" were dead "coming soon" rows.
// - Four routes nothing could reach (/login, /otp, /payment,
//   /payment-success) kept dead screens (and a second Razorpay flow) alive.

import 'dart:io';

import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/routes/routes.dart';
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
import 'package:arobo_app/screens/bookings_history_screen.dart';
import 'package:arobo_app/screens/my_account_screen.dart';
import 'package:arobo_app/screens/notifications_screen.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/link.dart' show LinkDelegate;
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../responsive/screen_responsive_harness.dart';

class _FakeLauncher extends UrlLauncherPlatform {
  final List<String> launched = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

Future<void> _quiet(Future<void> Function() body) async {
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
  tearDown(teardownScreenTestEnv);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('My Bookings opened for booking 5 opens that booking on top of the list', (tester) async {
    phone(tester);
    await _quiet(() async {
      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          home: const Scaffold(body: Text('HOME')),
          getPages: [GetPage(name: '/my-bookings', page: () => const BookingsScreen())],
        ),
      ));
      Get.toNamed('/my-bookings', arguments: {'booking_id': 5});
      await settle(tester);

      final detail = tester.widget<BookingsUpcomingScreen>(find.byType(BookingsUpcomingScreen));
      expect(detail.bookingId, 5);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });

  testWidgets('a tap on an in-app notification opens what it is about', (tester) async {
    phone(tester);
    Repository().dio.interceptors.insert(
      0,
      dio.InterceptorsWrapper(onRequest: (o, h) {
        if (o.path.contains('customer/notifications')) {
          return h.resolve(dio.Response(requestOptions: o, statusCode: 200, data: {
            'success': true,
            'data': {
              'notifications': [
                {
                  'id': 1,
                  'title': 'Your coupon ends tomorrow',
                  'message': 'Use it before it expires.',
                  'template_name': 'COUPON_EXPIRING',
                  'is_read': false,
                  'created_at': '2026-10-05T10:00:00.000Z',
                },
              ],
              'unread_count': 1,
            },
          }));
        }
        h.next(o);
      }),
    );
    await _quiet(() async {
      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          initialRoute: '/notifications',
          getPages: [
            GetPage(name: '/notifications', page: () => const NotificationScreen()),
            GetPage(name: '/coupon-code', page: () => const Scaffold(body: Text('COUPONS'))),
          ],
        ),
      ));
      await settle(tester);
      await tester.tap(find.text('Your coupon ends tomorrow'));
      await settle(tester);

      expect(find.text('COUPONS'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });

  testWidgets('"Rate us" opens the store listing, "Become Partner" the partner portal; no dead "Claims" row', (tester) async {
    phone(tester);
    final launcher = _FakeLauncher();
    final previousLauncher = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);
    await _quiet(() async {
      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) =>
            const GetMaterialApp(home: MyAccountScreen()),
      ));
      await settle(tester);

      expect(find.text('Claims'), findsNothing);

      for (final label in ['Rate us', 'Become Partner']) {
        final item = find.text(label);
        await tester.scrollUntilVisible(item, 200, scrollable: find.byType(Scrollable).first);
        await tester.tap(item);
        await settle(tester);
      }
      expect(launcher.launched, [
        'https://play.google.com/store/apps/details?id=com.aorbotreks.app',
        'https://partners.aorbotreks.co.in/',
      ]);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });

  test('no route nothing can reach; every route the app opens by name exists', () {
    final names = routes.map((p) => p.name).toSet();
    for (final dead in ['/login', '/otp', '/payment', '/payment-success']) {
      expect(names, isNot(contains(dead)));
    }
    final used = <String>{};
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final code = f
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      for (final m in RegExp(r"""(?:toNamed|offAllNamed|offNamed)\(\s*'(/[^']*)'""").allMatches(code)) {
        used.add(m.group(1)!);
      }
    }
    expect(used, isNotEmpty);
    for (final r in used) {
      expect(names, contains(r), reason: '$r is opened by name but not registered');
    }
  });
}

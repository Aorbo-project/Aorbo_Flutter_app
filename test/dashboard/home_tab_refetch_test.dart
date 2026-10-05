// Scan D4: switching tabs rebuilt Home, which re-fetched What's New, Top
// Treks, Seasonal Picks and the sponsored slots every time (blanking them
// into shimmer) and left one more calendar Worker on the permanent
// DashboardController per visit.

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/screens/dashboard_main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:sizer/sizer.dart';

import '../responsive/screen_responsive_harness.dart';

void main() {
  late Map<String, int> hits;

  setUp(() async {
    await installScreenTestEnv();
    hits = {};
    // In front of the harness's catch-all: count, and answer the Home
    // sections with well-formed empty content.
    Repository().dio.interceptors.insert(
      0,
      InterceptorsWrapper(onRequest: (options, handler) {
        for (final key in const [
          'discovery/whats-new',
          'discovery/seasonal-picks',
          'discovery/sponsored-slots',
        ]) {
          if (options.path.contains(key)) {
            hits[key] = (hits[key] ?? 0) + 1;
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'data': key.endsWith('whats-new') ? <dynamic>[] : <String, dynamic>{},
              },
            ));
          }
        }
        handler.next(options);
      }),
    );
    Get.find<DashboardController>().featuredDestinationsDioForTesting.interceptors.add(
          InterceptorsWrapper(onRequest: (options, handler) {
            hits['top-treks'] = (hits['top-treks'] ?? 0) + 1;
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'results': <dynamic>[]},
            ));
          }),
        );
  });

  tearDown(teardownScreenTestEnv);

  testWidgets('Home -> Bookings -> Home -> Account -> Home: each section fetched once, no Worker leak', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // The test font is wider than real fonts; overflow is covered by
    // test/responsive, not here.
    final previous = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('overflowed')) return;
      previous?.call(d);
    };
    try {
      final dash = Get.find<DashboardController>();
      Future<void> settle() async {
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump(const Duration(milliseconds: 150));
        }
      }

      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) =>
            const GetMaterialApp(home: DashboardMain()),
      ));
      await settle();
      final listenersOnFirstVisit = dash.calenderTrekDatesObserver.subject.length;

      for (final tab in [1, 0, 2, 0, 1, 0]) {
        dash.selectedScreen.value = tab;
        await settle();
      }

      expect(hits['discovery/whats-new'], 1);
      expect(hits['discovery/seasonal-picks'], 1);
      expect(hits['discovery/sponsored-slots'], 1);
      expect(hits['top-treks'], 1);
      expect(dash.calenderTrekDatesObserver.subject.length, listenersOnFirstVisit,
          reason: 'one calendar listener per mounted Home, not one per visit');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    } finally {
      FlutterError.onError = previous;
    }
  });

  test('a section that failed is fetched again on the next visit; forced reload refetches all', () async {
    final dash = Get.find<DashboardController>();
    var failWhatsNew = true;
    Repository().dio.interceptors.insert(
      0,
      InterceptorsWrapper(onRequest: (options, handler) {
        if (options.path.contains('discovery/whats-new') && failWhatsNew) {
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 503, data: {'success': false}),
            type: DioExceptionType.badResponse,
          ));
        }
        handler.next(options);
      }),
    );

    await dash.loadHomeContent();
    failWhatsNew = false;
    await dash.loadHomeContent();
    expect(hits['discovery/seasonal-picks'], 1, reason: 'fresh: not fetched again');
    expect(dash.whatsNewObserver.value.maybeWhen(success: (_) => true, orElse: () => false), isTrue);

    await dash.loadHomeContent(force: true);
    expect(hits['discovery/seasonal-picks'], 2);
  });
}

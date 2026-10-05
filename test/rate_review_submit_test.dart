// Scan D11: "Submit Feedback" had no in-flight guard (a double tap sent two
// reviews: "Thank you" then "You have already reviewed this booking"), and
// any failure erased the review the customer had typed.

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/screens/rate_review_screen.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'responsive/screen_responsive_harness.dart';

const _typed = 'Great guides and a well planned route.';

void main() {
  late int posts;
  late Duration replyDelay;
  late bool fail;

  setUp(() async {
    await installScreenTestEnv();
    posts = 0;
    replyDelay = const Duration(milliseconds: 300);
    fail = false;
    Repository().dio.interceptors.insert(
      0,
      dio.InterceptorsWrapper(onRequest: (o, h) async {
        if (o.method == 'POST' && o.path.endsWith(NetworkUrl.review)) {
          posts++;
          await Future<void>.delayed(replyDelay);
          if (fail) {
            return h.reject(dio.DioException(
              requestOptions: o,
              response: dio.Response(requestOptions: o, statusCode: 500, data: {'success': false}),
              type: dio.DioExceptionType.badResponse,
            ));
          }
          return h.resolve(dio.Response(requestOptions: o, statusCode: 200, data: {'success': true}));
        }
        h.next(o);
      }),
    );
  });

  tearDown(teardownScreenTestEnv);

  Future<void> openScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        home: const Scaffold(body: Text('BOOKING')),
        getPages: [GetPage(name: '/rate-review', page: () => const RateReviewScreen())],
      ),
    ));
    Get.toNamed('/rate-review', arguments: {
      'booking': const BookingHistoryData(id: 5, customerId: 9, trekId: 7, batchId: 3),
      'preSelectedRating': 5,
    });
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.enterText(find.byType(TextField).first, _typed);
    await tester.pump();
  }

  Future<void> run(WidgetTester tester, Future<void> Function() body) async {
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

  testWidgets('a double tap sends ONE review and the button shows it is sending', (tester) async {
    await run(tester, () async {
      await openScreen(tester);
      final submit = find.text('Submit Feedback');
      expect(submit, findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(submit);
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      expect(find.text('Sending your review...'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('Sending your review...'), warnIfMissed: false);
        await Future<void>.delayed(const Duration(milliseconds: 600));
      });
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(posts, 1);
      await tester.pump(const Duration(seconds: 5));
    });
  });

  testWidgets('a failed send keeps the typed review and lets the customer send again', (tester) async {
    await run(tester, () async {
      fail = true;
      replyDelay = const Duration(milliseconds: 20);
      await openScreen(tester);

      await tester.runAsync(() async {
        await tester.tap(find.text('Submit Feedback'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(posts, 1);
      expect(Get.find<TrekController>().reviewController.value.text, _typed);
      expect(find.text('Submit Feedback'), findsOneWidget, reason: 'unlocked again');
      await tester.pump(const Duration(seconds: 5));
    });
  });

  testWidgets('"already reviewed" from the server counts as saved (the review exists)', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
    final c = Get.find<TrekController>();
    c.reviewController.value.text = _typed;
    Repository().dio.interceptors.insert(
      0,
      dio.InterceptorsWrapper(onRequest: (o, h) {
        if (o.path.endsWith(NetworkUrl.review)) {
          return h.reject(dio.DioException(
            requestOptions: o,
            response: dio.Response(
              requestOptions: o,
              statusCode: 400,
              data: {'success': false, 'message': 'You have already reviewed this booking'},
            ),
            type: dio.DioExceptionType.badResponse,
          ));
        }
        h.next(o);
      }),
    );
    late bool saved;
    await tester.runAsync(() async {
      saved = await c.createReview(
        trekId: 7, customerId: 9, bookingId: 5, batchId: 3,
        safetySecurity: false, organizerManner: false, trekPlanning: false, womenSafety: false,
      );
    });
    await tester.pump();
    expect(saved, isTrue);
    expect(c.reviewController.value.text, isEmpty, reason: 'saved -> cleared');
    await tester.pump(const Duration(seconds: 5));
  });
}

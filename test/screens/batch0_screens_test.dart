// Review C L14: batch-0 fixes that were only tested through helpers now get
// a test on the real screen.
// - E0-3: a batch the organiser closed shows "Bookings Closed" (disabled),
//   not "Continue", on the trek page.
// - E0-6: the booking page hides "Cancel" when the server says can_cancel
//   false, and says why; it shows it when allowed.
// - E0-5: a dropped coupon is explained in words, not a code.

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:arobo_app/repository/api_result.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:dio/dio.dart' as dio;
import 'package:arobo_app/screens/booking_upcoming_screen.dart';
import 'package:arobo_app/screens/trek_details_screen.dart';
import 'package:arobo_app/services/analytics_service.dart';
import 'package:arobo_app/services/app_feedback.dart';
import 'package:arobo_app/utils/coupon_rejection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../responsive/screen_responsive_harness.dart';

const _lock = 'Cancellation closes 6 hours before departure.';

/// Serves one booking detail instead of calling the server.
class _OneBookingDashboard extends DashboardController {
  _OneBookingDashboard(this.booking);
  final BookingHistoryData booking;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> getBookingDetail({required dynamic bookingId}) async {
    bookingDetailsObserver.value =
        ApiResult.success(BookingDetailsResponseModel(success: true, data: booking));
  }

  @override
  Future<void> getBookingHistory({required bool refresh}) async {}

  @override
  Future<void> fetchDetailScreenAds(String screen) async {}
}

BookingHistoryData _booking({bool? canCancel, String? message}) => BookingHistoryData.fromJson({
      'id': 77,
      'booking_number': 'BI77',
      'status': 'confirmed',
      'can_cancel': canCancel,
      'cancellation_message': message,
      'batch': {'id': 9, 'start_date': '2099-01-10', 'end_date': '2099-01-14'},
      'trek': {'id': 7, 'title': 'Kedarkantha'},
    });

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

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(Sizer(
    builder: (context, orientation, deviceType) => GetMaterialApp(home: screen),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
  AnalyticsService.instance.resetForTest();
}

void main() {
  group('E0-3: trek page bottom button', () {
    setUp(installScreenTestEnv);
    tearDown(teardownScreenTestEnv);

    for (final closed in [true, false]) {
      testWidgets(closed ? 'organiser closed the batch -> "Bookings Closed", disabled' : 'open batch -> "Continue"', (tester) async {
        await _quiet(() async {
          Get.find<TrekController>().trekDetailData.value = TrekDetailData(
            id: 7,
            title: 'Kedarkantha',
            batchId: 9,
            bookingsStoppedAt: closed ? '2026-10-01T10:00:00.000Z' : null,
          );
          await _pump(tester, TrekDetailsScreen(trek: null));

          expect(find.text('Bookings Closed'), closed ? findsOneWidget : findsNothing);
          expect(find.text('Continue'), closed ? findsNothing : findsOneWidget);
          await _unmount(tester);
        });
      });
    }
  });

  group('E0-6: booking page Cancel button', () {
    for (final allowed in [false, true]) {
      testWidgets(allowed ? 'can_cancel true -> "Cancel" shown' : 'can_cancel false -> no "Cancel", the reason is shown', (tester) async {
        Get.testMode = true;
        Get.put<DashboardController>(
          _OneBookingDashboard(_booking(canCancel: allowed, message: allowed ? null : _lock)),
          permanent: true,
        );
        await installScreenTestEnv();
        addTearDown(teardownScreenTestEnv);
        await _quiet(() async {
          await _pump(tester, const BookingsUpcomingScreen(bookingId: 77));

          expect(find.text('Cancel'), allowed ? findsOneWidget : findsNothing);
          expect(find.text(_lock), allowed ? findsNothing : findsOneWidget);
          await _unmount(tester);
        });
      });
    }
  });

  group('E0-5: a dropped coupon is explained in words', () {
    setUp(installScreenTestEnv);
    tearDown(teardownScreenTestEnv);

    testWidgets('calculate-fare drops a coupon with only a code -> the customer sees the sentence', (tester) async {
      AppFeedback.dismissAll(); // a toast cut short by an earlier test
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));
      // In front of the harness's catch-all reply.
      Repository().dio.interceptors.insert(
        0,
        dio.InterceptorsWrapper(onRequest: (o, h) {
          if (o.path.contains(NetworkUrl.calculateFare)) {
            return h.resolve(dio.Response(requestOptions: o, statusCode: 200, data: {
              'success': true,
              'fareToken': 'tok',
              'breakdown': {'final_amount': 2999, 'amount_to_pay_now': 999},
              'coupon_rejected_reason': '',
              'coupon_rejected_code': 'FLEXIBLE_ADVANCE_EXCEEDS_FARE',
            }));
          }
          h.next(o);
        }),
      );
      // This headless harness has no toast overlay: AppFeedback prints the
      // toast text instead (same fallback the payment-screen tests read).
      final shown = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) shown.add(message);
      };
      try {
        await tester.runAsync(() => Get.find<TrekController>().calculateFare());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(shown.where((m) => m.contains(flexibleAdvanceExceedsFareMessage)), isNotEmpty, reason: '$shown');
      expect(shown.where((m) => m.contains('FLEXIBLE_ADVANCE_EXCEEDS_FARE')), isEmpty);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}

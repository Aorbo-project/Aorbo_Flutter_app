// Scan E0-6: the booking-detail screen's Cancel button follows the detail
// reply's can_cancel (now sent), then the list item's, then "allowed"; and a
// failed detail load says so in plain words (it used to say "dispute").

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/utils/booking_cancel_eligibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'trek_controller_test.dart' show setUpController, installFakeBackend;

const _lock = 'Cancellation closes 6 hours before departure.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveCancelEligibility', () {
    test("the detail's can_cancel wins over the list item's", () {
      final r = resolveCancelEligibility(
        detail: const BookingHistoryData(id: 1, canCancel: false, cancellationMessage: _lock),
        listItem: const BookingHistoryData(id: 1, canCancel: true),
      );
      expect(r.allowed, isFalse);
      expect(r.message, _lock);

      final allowed = resolveCancelEligibility(
        detail: const BookingHistoryData(id: 1, canCancel: true),
        listItem: const BookingHistoryData(id: 1, canCancel: false, cancellationMessage: _lock),
      );
      expect(allowed.allowed, isTrue);
      expect(allowed.message, isNull, reason: 'message comes from the same source as the flag');
    });

    test('a detail without can_cancel falls back to the list item', () {
      final r = resolveCancelEligibility(
        detail: const BookingHistoryData(id: 1),
        listItem: const BookingHistoryData(id: 1, canCancel: false, cancellationMessage: _lock),
      );
      expect(r.allowed, isFalse);
      expect(r.message, _lock);
    });

    test('neither says → allowed (the server re-checks on submit)', () {
      expect(resolveCancelEligibility(detail: const BookingHistoryData(id: 1)).allowed, isTrue);
      expect(
        resolveCancelEligibility(
          detail: const BookingHistoryData(id: 1),
          listItem: const BookingHistoryData(id: 1),
        ).allowed,
        isTrue,
      );
    });

    test('a blank message is no message', () {
      final r = resolveCancelEligibility(
        detail: const BookingHistoryData(id: 1, canCancel: false, cancellationMessage: '  '),
      );
      expect(r.allowed, isFalse);
      expect(r.message, isNull);
    });

    test('booking-details reply fields parse (trek_status, can_cancel, cancellation_message, rating_*)', () {
      final m = BookingDetailsResponseModel.fromJson({
        'success': true,
        'data': {
          'id': 9,
          'trek_status': 'upcoming',
          'can_cancel': false,
          'cancellation_message': _lock,
          'rating_given': false,
          'rating_value': null,
        },
      });
      final r = resolveCancelEligibility(detail: m.data!);
      expect(m.data!.trekStatus, 'upcoming');
      expect(r.allowed, isFalse);
      expect(r.message, _lock);
    });
  });

  group('DashboardController.getBookingDetail error text', () {
    tearDown(() {
      Repository().dio.interceptors.clear();
      Get.reset();
    });

    String? errorOf(DashboardController d) => d.bookingDetailsObserver.value
        .maybeWhen(error: (m) => m, orElse: () => null);

    test('a failed load says "Couldn\'t load booking details", not "dispute"', () async {
      await setUpController();
      installFakeBackend({
        NetworkUrl.bookingDetails(5): (_) => {
          '__error__': true,
          'statusCode': 500,
          'data': {'message': 'Internal error'},
        },
      });
      final d = DashboardController();
      await d.getBookingDetail(bookingId: 5);
      expect(errorOf(d), bookingDetailsLoadError);
      expect(bookingDetailsLoadError, "Couldn't load booking details");
    });

    test('success:false without a message uses the same text', () async {
      await setUpController();
      installFakeBackend({
        NetworkUrl.bookingDetails(6): (_) => {'success': false},
      });
      final d = DashboardController();
      await d.getBookingDetail(bookingId: 6);
      expect(errorOf(d), bookingDetailsLoadError);
    });
  });
}

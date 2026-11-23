// Owner test, 23 Nov 2026: booking 1909 was cancelled on the server (refund
// sent), but the cancel screen was closed during the ~2 s request, so the
// success screen never came. The booking screen underneath still offered
// "Cancel", and three taps each showed "Booking is already cancelled".
//
// Fixed in three places; this file guards them:
//   1. Back is blocked while the cancellation request runs (PopScope).
//   2. If the screen closes anyway, a successful cancellation still refreshes
//      the booking and tells the customer.
//   3. "Already cancelled" from the server is not an error: the app refreshes
//      that booking (so Cancel disappears) and says so in plain words.

import 'dart:io';

import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'trek_controller_test.dart' show setUpController, installFakeBackend;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Repository().dio.interceptors.clear();
    Get.reset();
  });

  test('"already cancelled" from the server: plain message, and the booking is refreshed', () async {
    final c = await setUpController();
    var detailCalls = 0;
    installFakeBackend({
      NetworkUrl.refundDetail('1909'): (_) => {
            '__error__': true,
            'statusCode': 409,
            'data': {'success': false, 'message': 'Booking is already cancelled'},
          },
      'booking-details/1909': (_) {
        detailCalls++;
        return {
          'success': true,
          'data': {'id': 1909, 'status': 'cancelled', 'can_cancel': false},
        };
      },
    });

    final message = await c.fetchCancellationDetails('1909');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(message, 'This booking is already cancelled.');
    expect(detailCalls, greaterThanOrEqualTo(1)); // the stale screen gets the cancelled booking
  });

  test('guard: the cancel screen blocks back while cancelling, and handles a closed screen', () {
    final src = File('lib/screens/booking_cancle_screen.dart').readAsStringSync();
    expect(src, contains('canPop: !_isCancelling'));
    // After a successful request on a closed screen: refresh + tell the customer.
    final closedBranch = RegExp(r'if \(!mounted\) \{[\s\S]{0,700}?getBookingDetail\(bookingId: bookingId\)');
    expect(closedBranch.hasMatch(src), isTrue);
  });
}

// Owner, 24 Nov 2026: an organiser's offline ticket in My Bookings is view-only for money —
// no cancel, refund or payment in the app (the customer paid the organiser directly).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/offline_ticket/offline_ticket.dart';

void main() {
  test('an offline ticket is recognised by booking_source', () {
    expect(isOfflineTicket(const BookingHistoryData(bookingSource: 'offline_ticket')), isTrue);
    expect(isOfflineTicket(const BookingHistoryData(bookingSource: 'app')), isFalse);
    expect(isOfflineTicket(const BookingHistoryData()), isFalse);
  });

  test('the preview is off unless switched on at build time', () {
    expect(kOfflineTicketPreview, isFalse);
  });

  test('guard: the ticket screen has no cancel, refund or pay action', () {
    final src = File('lib/offline_ticket/offline_ticket_screen.dart').readAsStringSync();
    expect(src, isNot(contains('BookingCancelScreen')));
    expect(src, isNot(matches(RegExp(r'cancelBooking|requestRefund|createOrder|Razorpay', caseSensitive: false))));
  });

  test('guard: offline tickets never trigger "Booked just now"', () {
    final src = File('lib/screens/bookings_history_screen.dart').readAsStringSync();
    final fn = src.substring(src.indexOf('BookingHistoryData? _justBookedBooking'));
    expect(fn.substring(0, 900), contains('isOfflineTicket(b)'));
  });
}

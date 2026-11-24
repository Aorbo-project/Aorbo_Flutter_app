// Owner, 24 Nov 2026: an organiser's offline ticket shows in My Bookings and opens the
// SAME Booking Details screen as any booking (it must blend with the app), but it is
// view-only for money: no cancel, refund tracker or ticket download, payment shows what
// was paid to the organiser. Rate & review after the trip is allowed.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/offline_ticket/offline_ticket.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll(String.fromCharCode(13), '');

void main() {
  final details = _read('lib/screens/booking_upcoming_screen.dart');

  test('an offline ticket is recognised by booking_source', () {
    expect(isOfflineTicket(const BookingHistoryData(bookingSource: 'offline_ticket')), isTrue);
    expect(isOfflineTicket(const BookingHistoryData(bookingSource: 'app')), isFalse);
    expect(isOfflineTicket(null), isFalse);
  });

  test('the preview is off unless switched on at build time', () {
    expect(kOfflineTicketPreview, isFalse);
    expect(offlineTicketSampleFor('OB20260012'), isNull);
  });

  test('no separate ticket screen: it uses the normal Booking Details screen', () {
    expect(File('lib/offline_ticket/offline_ticket_screen.dart').existsSync(), isFalse);
  });

  test('guard: cancel is never allowed on an offline ticket', () {
    final cancelRule = details.substring(details.indexOf('final bool statusAllowsCancel'));
    expect(cancelRule.substring(0, 400), contains('!isOfflineTicket(booking)'));
  });

  test('guard: no refund tracker, no ticket download, organiser payment rows', () {
    expect(details, contains("booking != null &&\n                          !isOfflineTicket(booking)) ...["));
    expect(details, contains("if (!isOfflineTicket(booking))\n                            Expanded("));
    expect(details, contains('if (isOfflineTicket(booking)) return _offlinePaymentRows(booking);'));
  });

  test('one ID everywhere: an offline ticket shows its Booking ID, highlighted', () {
    final rows = details.substring(details.indexOf('List<Widget> _offlineBookingRows'));
    expect(rows.substring(0, 700), contains("_ticketRow('Booking ID', b.bookingNumber ?? 'N/A', isHighlight: true)"));
    expect(details, isNot(contains("'Ticket No.'")));
  });

  test('guard: customers never see internal ids such as Destination ID', () {
    expect(details, isNot(contains("'Destination ID'")));
  });

  test('guard: offline tickets never trigger "Booked just now"', () {
    final src = _read('lib/screens/bookings_history_screen.dart');
    final fn = src.substring(src.indexOf('BookingHistoryData? _justBookedBooking'));
    expect(fn.substring(0, 900), contains('isOfflineTicket(b)'));
  });

  test('an offline ticket opens by its booking ID (it has no app booking row)', () {
    final src = _read('lib/screens/bookings_history_screen.dart');
    final card = src.substring(src.indexOf('Widget _commonCard('));
    expect(card.substring(0, 700), contains('BookingsUpcomingScreen(bookingId: number)'));
    expect(src, contains('final key = b.id ?? b.bookingNumber ?? b;'));
  });

  test('no Rate button on offline tickets until their reviews are built on the server', () {
    expect(_read('lib/utils/common_booked_card.dart'), contains('!isOfflineTicket(booking)'));
    final fab = details.substring(details.indexOf('final bool showRatingFab'));
    expect(fab.substring(0, 400), contains('!isOfflineTicket(booking)'));
  });

  test('"Not my booking" calls the server', () {
    expect(details, contains('_dashboardC.hideOfflineTicket(number)'));
    expect(_read('lib/repository/network_url.dart'), contains("'bookings/offline-tickets/"));
  });
}

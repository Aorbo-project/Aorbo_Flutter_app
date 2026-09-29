import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/services/ticket_share_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicketShareService.shareText', () {
    test('names the trek and IST departure date, ends with the app link', () {
      const booking = BookingHistoryData(
        bookingNumber: 'BI20260150',
        trek: Trek(title: 'Spl Coorg Chikkamagaluru'),
        batch: Batch(startDate: '2026-07-30T06:30:00.000Z'),
      );

      expect(
        TicketShareService.shareText(booking),
        'The mountains are calling, and I must go 🏔️\n'
        'Booked Spl Coorg Chikkamagaluru on Aorbo Treks — Thu, 30 Jul 2026. '
        'Ticket attached!\n\n'
        'Your next adventure is one tap away. '
        'Download the Aorbo Treks app from Google Play 👇\n'
        'https://play.google.com/store/apps/details?id=com.aorbotreks.app',
      );
    });

    test('still reads cleanly without a title or date', () {
      final text = TicketShareService.shareText(const BookingHistoryData());

      expect(text, contains('\nBooked my trek on Aorbo Treks. Ticket attached!\n'));
      expect(text, isNot(contains('N/A')));
      expect(text, endsWith(TicketShareService.appLink));
    });
  });
}

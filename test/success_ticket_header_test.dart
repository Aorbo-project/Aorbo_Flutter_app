// Scan E0-2: the success ticket must not be blank when the verify reply
// carries a bare booking (the webhook completed it first on older servers).

import 'package:arobo_app/freezed_models/booking/booking_history_model.dart'
    as history;
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:arobo_app/models/treaks/verify_order_modal.dart' as verify;
import 'package:arobo_app/utils/success_ticket_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('full verify reply: its own trek and batch are used', () {
    final data = verify.Data.fromJson({
      'id': 1,
      'trek_id': 7,
      'batch_id': 9,
      'trek': {
        'id': 7,
        'title': 'Kedarkantha',
        'duration': '5 Days 4 Nights',
        'destinationData': {'id': 1, 'name': 'Sankri'},
      },
      'batch': {'id': 9, 'start_date': '2026-12-01', 'end_date': '2026-12-05'},
    });
    final h = SuccessTicketHeader.resolve(
      data: data,
      trek: const TrekDetailData(id: 7, title: 'Other title'),
    );
    expect(h.title, 'Kedarkantha');
    expect(h.duration, '5 Days 4 Nights');
    expect(h.destination, 'Sankri');
    expect(h.startDate, '2026-12-01');
    expect(h.endDate, '2026-12-05');
  });

  test('bare booking: falls back to the booking-detail reply', () {
    final data = verify.Data.fromJson({'id': 1, 'trek_id': 7, 'batch_id': 9});
    const booking = history.BookingHistoryData(
      id: 1,
      trek: history.Trek(
        id: 7,
        title: 'Kedarkantha',
        duration: '5D',
        destination: history.Destination(name: 'Sankri'),
      ),
      batch: history.Batch(id: 9, startDate: '2026-12-01', endDate: '2026-12-05'),
    );
    final h = SuccessTicketHeader.resolve(data: data, booking: booking);
    expect(h.title, 'Kedarkantha');
    expect(h.destination, 'Sankri');
    expect(h.startDate, '2026-12-01');
  });

  test('bare booking, detail not loaded yet: the trek being booked (same trek/batch only)', () {
    final data = verify.Data.fromJson({'id': 1, 'trek_id': 7, 'batch_id': 9});
    const sameTrek = TrekDetailData(
      id: 7,
      title: 'Kedarkantha',
      batchId: 9,
      startDate: '2026-12-01',
      endDate: '2026-12-05',
      destinationData: Activities(name: 'Sankri'),
    );
    final h = SuccessTicketHeader.resolve(data: data, trek: sameTrek);
    expect(h.title, 'Kedarkantha');
    expect(h.startDate, '2026-12-01');
    expect(h.destination, 'Sankri');

    // Same trek, different batch: name yes, dates no.
    final otherBatch = SuccessTicketHeader.resolve(
      data: data,
      trek: sameTrek.copyWith(batchId: 10),
    );
    expect(otherBatch.title, 'Kedarkantha');
    expect(otherBatch.startDate, isNull);

    // A different trek is never used.
    final otherTrek = SuccessTicketHeader.resolve(
      data: data,
      trek: sameTrek.copyWith(id: 8),
    );
    expect(otherTrek.title, isNull);
  });
}

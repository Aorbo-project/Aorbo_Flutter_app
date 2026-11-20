// Owner, 11 Nov 2026: "the server is the source of truth". The phone-built invoice
// (fallback when the server's PDF can't be fetched) prints the cancellation table the
// server sends on GET /api/v1/bookings (cancellation_table) — it used to work the
// amounts out itself on the total with GST + fees.
import 'dart:convert';
import 'dart:io';

import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/services/invoice_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Exactly what the server sent for a seeded Standard booking (real route, 11 Nov 2026).
const _serverTable = {
  'heading': 'Standard policy — deducted from the trek fare after discounts',
  'rows': [
    {'when': 'Before 08 Dec 2026 (72 h or more)', 'deduction': '20% · ₹800'},
    {'when': '08 Dec 2026 – 09 Dec 2026', 'deduction': '50% · ₹2,000'},
    {'when': '09 Dec 2026 – 10 Dec 2026', 'deduction': '70% · ₹2,800'},
    {'when': 'After 10 Dec 2026, after departure or no-show', 'deduction': '100% · ₹4,000'},
  ],
  'notes': ['Refunds go back to the original payment method and usually take 5–7 business days.'],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the booking list reply carries the server table into the model', () {
    final b = BookingHistoryData.fromJson({
      'id': 7,
      'booking_number': 'BI-7',
      'cancellation_table': _serverTable,
    });
    expect(b.cancellationTable?['heading'], _serverTable['heading']);
    expect((b.cancellationTable?['rows'] as List).length, 4);
  });

  test('it survives the hand-off to the PDF isolate (jsonEncode → fromJson)', () {
    final b = BookingHistoryData.fromJson({'id': 7, 'cancellation_table': _serverTable});
    final back = BookingHistoryData.fromJson(jsonDecode(jsonEncode(b)) as Map<String, dynamic>);
    expect(back.cancellationTable, b.cancellationTable);
  });

  test('the invoice builds with the server table, and without it (old cached booking)', () async {
    for (final table in [_serverTable, null]) {
      final bytes = await InvoicePdfService.generateInvoice(
        booking: BookingHistoryData.fromJson({
          'id': 8,
          'booking_number': 'BI-8',
          'cancellation_policy_type': 'standard',
          'final_amount': '4735.00',
          'cancellation_table': table,
        }),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    }
  });

  test('the app works no cancellation amounts out itself', () {
    final src = File('lib/services/invoice_pdf_service.dart').readAsStringSync();
    expect(src, contains('_ServerCancellationTable.from(booking.cancellationTable)'));
    // no slab percentages, no advance maths, no "total fare" base, no vendor-decides text
    expect(src, isNot(matches(RegExp(r'\*\s*0\.(20|50|70)\b'))));
    expect(src, isNot(contains("booking.advanceAmount ?? '999'")));
    expect(src, isNot(contains('calculated based on a total fare')));
    expect(src, isNot(contains('determined and approved by the respective vendor')));
  });
}

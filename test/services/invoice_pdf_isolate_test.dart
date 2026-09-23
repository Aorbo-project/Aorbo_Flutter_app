import 'dart:convert';

import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/freezed_models/profile/user_profile_model.dart' show Traveler;
import 'package:arobo_app/services/invoice_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

// generateInvoice() builds the PDF on a background isolate (compute()) so the
// synchronous pdf layout/save no longer freezes the UI thread on every
// booking. A first attempt loaded assets inside the isolate and serialized
// with booking.toJson() alone — both failed their own tests (asset channels
// aren't reliable off the root isolate; toJson() leaves nested Freezed
// objects un-serialized). These lock in the working design: assets loaded
// up front, booking sent as jsonEncode'd plain JSON, and the round trip
// provably lossless.

const _populated = BookingHistoryData(
  id: 42,
  bookingNumber: 'AORBO-TEST-42',
  status: 'confirmed',
  paymentStatus: 'full_paid',
  totalAmount: '10000',
  finalAmount: '9500',
  bookingDate: '2026-10-01',
  trek: Trek(
    title: 'Test Trek',
    captainName: 'Test Captain',
    captainPhone: '9876543210',
    durationDays: 3,
    durationNights: 2,
    vendor: Vendor(businessName: 'Test Vendor', phone: '9123456789'),
  ),
  batch: Batch(tbrId: 'TBR-TEST-42', startDate: '2026-10-01', endDate: '2026-10-03'),
  travelers: [
    TravelersDataModel(traveler: Traveler(name: 'Traveler One', age: 25, gender: 'Male')),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a populated booking survives the jsonEncode -> fromJson round trip losslessly', () {
    final roundTripped = BookingHistoryData.fromJson(
      jsonDecode(jsonEncode(_populated)) as Map<String, dynamic>,
    );
    expect(roundTripped, _populated);
  });

  test('booking.toJson() alone does NOT deep-serialize nested models (why jsonEncode is required)', () {
    expect(_populated.toJson()['trek'], isNot(isA<Map<String, dynamic>>()));
  });

  test('generateInvoice() on a minimal booking returns a valid PDF', () async {
    final bytes = await InvoicePdfService.generateInvoice(
      booking: const BookingHistoryData(bookingNumber: 'TEST-001'),
    );
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('generateInvoice() on a populated booking returns a valid PDF', () async {
    final bytes = await InvoicePdfService.generateInvoice(booking: _populated);
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}

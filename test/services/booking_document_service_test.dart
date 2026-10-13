import 'dart:typed_data';

import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';
import 'package:arobo_app/services/booking_document_service.dart';
import 'package:flutter_test/flutter_test.dart';

// 13 Oct 2026: the Ticket / Share buttons use the receipt the SERVER issues;
// the phone-built PDF is only the fallback (offline, older server).

Uint8List _pdf(String tag) => Uint8List.fromList('%PDF-1.4\n% $tag\n%%EOF\n'.codeUnits);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const booking = BookingHistoryData(bookingNumber: 'BI20261267');
  final original = BookingDocumentService.download;
  tearDown(() => BookingDocumentService.download = original);

  test("uses the server's PDF, asked for by booking number", () async {
    String? asked;
    BookingDocumentService.download = (url) async {
      asked = url;
      return _pdf('server');
    };
    final bytes = await BookingDocumentService.fetch(booking);
    expect(asked, 'customer/bookings/BI20261267/invoice');
    expect(String.fromCharCodes(bytes), contains('server'));
  });

  test('server unreachable -> the phone-built PDF instead', () async {
    BookingDocumentService.download = (url) async => throw Exception('offline');
    final bytes = await BookingDocumentService.fetch(booking);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(String.fromCharCodes(bytes), isNot(contains('server')));
  });

  test('a reply that is not a PDF (e.g. a JSON error) is never shown as the ticket', () async {
    BookingDocumentService.download = (url) async => Uint8List.fromList('{"success":false}'.codeUnits);
    final bytes = await BookingDocumentService.fetch(booking);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('no booking number -> straight to the phone-built PDF, no request', () async {
    var called = false;
    BookingDocumentService.download = (url) async {
      called = true;
      return _pdf('server');
    };
    final bytes = await BookingDocumentService.fetch(const BookingHistoryData());
    expect(called, isFalse);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}

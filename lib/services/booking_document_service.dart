import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../widgets/logger.dart';
import 'invoice_pdf_service.dart';

/// The booking's receipt / invoice PDF (13 Oct 2026).
///
/// The SERVER issues it now — with its own document number, the stored
/// booking figures and the issuer details (GET customer/bookings/<no>/invoice).
/// The phone-built PDF ([InvoicePdfService]) is only the fallback, so the
/// Ticket and Share buttons still work offline or against an older server.
class BookingDocumentService {
  BookingDocumentService._();

  /// Test seam: replace to fake the server download.
  static Future<Uint8List?> Function(String url) download =
      (url) => Repository().getBytes(url: url);

  static bool _isPdf(Uint8List? bytes) =>
      bytes != null &&
      bytes.length > 5 &&
      String.fromCharCodes(bytes.sublist(0, 5)) == '%PDF-';

  /// The server's PDF, else the one built on the phone.
  static Future<Uint8List> fetch(BookingHistoryData booking) async {
    final number = booking.bookingNumber;
    if (number != null && number.isNotEmpty) {
      try {
        final bytes = await download(NetworkUrl.bookingDocument(number));
        if (_isPdf(bytes)) return bytes!;
        logger.w('BookingDocumentService: server reply was not a PDF');
      } catch (e) {
        logger.w('BookingDocumentService: server document unavailable', error: e);
      }
    }
    return InvoicePdfService.generateInvoice(
      booking: booking,
      policyType: booking.cancellationPolicyType?.toString(),
    );
  }

  /// Opens the system PDF viewer / print sheet on the booking's document.
  static Future<void> preview(BookingHistoryData booking) async {
    final bytes = await fetch(booking);
    await Printing.layoutPdf(
      name: 'AorboTreks_${booking.bookingNumber ?? 'booking'}.pdf',
      onLayout: (_) async => bytes,
    );
  }
}

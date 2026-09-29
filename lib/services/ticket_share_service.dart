import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../freezed_models/booking/booking_history_model.dart';
import '../utils/ist_date_utils.dart';
import 'invoice_pdf_service.dart';

/// Shares a booking the way ticketing apps do: the ticket PDF itself (the
/// same document the Ticket button opens) with a short note and the app link.
class TicketShareService {
  TicketShareService._();

  static const String appLink =
      'https://play.google.com/store/apps/details?id=com.aorbotreks.app';

  static String shareText(BookingHistoryData booking) {
    final title = booking.trek?.title ?? '';
    final start = ISTDateUtils.toIST(booking.batch?.startDate);
    final trip = title.isNotEmpty ? title : 'my trek';
    final when =
        start != null ? ' — ${DateFormat('E, d MMM yyyy').format(start)}' : '';
    return 'The mountains are calling, and I must go 🏔️\n'
        'Booked $trip on Aorbo Treks$when. Ticket attached!\n\n'
        'Your next adventure is one tap away. '
        'Download the Aorbo Treks app from Google Play 👇\n'
        '$appLink';
  }

  /// Builds the ticket PDF into a temp file. Split from [share] so callers can
  /// close their progress dialog before the share sheet opens (the sheet's
  /// Future only completes when it is dismissed).
  static Future<XFile> prepareTicket(BookingHistoryData booking) async {
    final bytes = await InvoicePdfService.generateInvoice(
      booking: booking,
      policyType: booking.cancellationPolicyType?.toString(),
    );
    final ref = (booking.bookingNumber ?? 'booking')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    final name = 'Aorbo_Ticket_$ref.pdf';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path, mimeType: 'application/pdf', name: name);
  }

  static Future<void> share(XFile ticket, BookingHistoryData booking) async {
    await Share.shareXFiles(
      [ticket],
      text: shareText(booking),
      subject: 'Aorbo Treks ticket — ${booking.trek?.title ?? ''}',
    );
  }
}

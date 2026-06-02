import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePdfService {
  // ─────────────────────────────────────────────
  //  COLORS
  // ─────────────────────────────────────────────
  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _inkMid = PdfColor.fromInt(0xFF64748B);
  static const _inkLight = PdfColor.fromInt(0xFF94A3B8);
  static const _brand = PdfColor.fromInt(0xFF4271FF);
  static const _green = PdfColor.fromInt(0xFF0F7B6C);
  static const _red = PdfColor.fromInt(0xFFDC2626);
  static const _divider = PdfColor.fromInt(0xFFE2E8F0);
  static const _yellowBg = PdfColor.fromInt(0xFFFFF8E1);
  static const _aorboYellow = PdfColor.fromInt(0xFFFFD500);
  static const _chipBg = PdfColor.fromInt(0xFFF1F5F9);

  // ─────────────────────────────────────────────
  //  STATIC SAMPLE DATA
  // ─────────────────────────────────────────────
  static const String _bookingNumber = 'AOR-2025-00123';
  static const String _tbrId = 'TBR-998877';
  static const String _bookingStatus = 'CONFIRMED';
  static const String _paymentStatus = 'full_paid';

  static final DateTime _bookingDate = DateTime(2025, 11, 12, 14, 30);
  static final DateTime _startDate = DateTime(2025, 12, 20, 6, 0);
  static final DateTime _endDate = DateTime(2025, 12, 22, 18, 0);

  // Vendor
  static const String _vendorName = 'Himalayan Trail Adventures';
  static const String _vendorAddress =
      '123, MG Road, Rishikesh, Uttarakhand - 249201';
  static const String _vendorPhone = '+91 98765 43210';
  static const String _vendorEmail = 'support@himalayantrails.com';
  static const String _vendorCity = 'Rishikesh';

  // Trek
  static const String _trekTitle = 'Kedarkantha Winter Trek';
  static const String _trekDescription =
      'A 3-day snow trek through pine forests, frozen lakes and panoramic Himalayan summits.';
  static const String _trekDuration = '3 Days 2 Nights';
  static const String _captainName = 'Rohit Sharma';
  static const String _captainPhone = '+91 91234 56789';
  static const String _boardingPoint = 'Sankri Base Camp, Uttarakhand';

  // Travelers
  static const List<Map<String, String>> _travelers = [
    {'name': 'Aarav Mehta', 'age': '28', 'gender': 'Male'},
    {'name': 'Priya Sharma', 'age': '26', 'gender': 'Female'},
    {'name': 'Karan Patel', 'age': '30', 'gender': 'Male'},
  ];

  // Payment
  static const String _baseFare = '5500';
  static const String _insurance = '200';
  static const String _gst = '299';
  static const String _discount = '0';
  static const String _finalAmount = '5999';
  static const String _paidAmount = '5999';
  static const String _pendingAmount = '0';

  // ─────────────────────────────────────────────
  //  PUBLIC: GENERATE PDF
  // ─────────────────────────────────────────────
  static Future<Uint8List> generateInvoice({
    String policyType = 'standard',
  }) async {
    final doc = pw.Document(
      title: 'Aorbo Treks Invoice - $_bookingNumber',
      author: 'Aorbo Treks',
    );

    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontSemi = await PdfGoogleFonts.poppinsSemiBold();
    final fontItalic = await PdfGoogleFonts.poppinsItalic();

    pw.MemoryImage? vendorLogo;
    pw.MemoryImage? aorboLogo;

    try {
      final aorboBytes = await rootBundle.load(
        'assets/images/img/aorbologo.png',
      );
      aorboLogo = pw.MemoryImage(aorboBytes.buffer.asUint8List());
    } catch (_) {}

    const vendorLogoUrl = '';
    if (vendorLogoUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(vendorLogoUrl));
        if (response.statusCode == 200) {
          vendorLogo = pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {}
    }

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
      italic: fontItalic,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildInvoiceBody(
            policyType: policyType,
            font: font,
            fontBold: fontBold,
            fontSemi: fontSemi,
            fontItalic: fontItalic,
            vendorLogo: vendorLogo,
            aorboLogo: aorboLogo,
          ),
          pw.SizedBox(height: 20),
          _buildDisclaimer(fontBold: fontBold, fontSemi: fontSemi),
        ],
      ),
    );

    return doc.save();
  }

  // ─────────────────────────────────────────────
  //  PUBLIC: SHARE / PREVIEW
  // ─────────────────────────────────────────────
  static Future<void> shareInvoice({String policyType = 'standard'}) async {
    final bytes = await generateInvoice(policyType: policyType);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Aorbo_Invoice_$_bookingNumber.pdf',
    );
  }

  static Future<void> previewInvoice({String policyType = 'standard'}) async {
    await Printing.layoutPdf(
      name: 'Aorbo_Invoice_$_bookingNumber.pdf',
      onLayout: (format) => generateInvoice(policyType: policyType),
    );
  }

  // ─────────────────────────────────────────────
  //  INVOICE BODY
  // ─────────────────────────────────────────────
  static pw.Widget _buildInvoiceBody({
    required String policyType,
    required pw.Font font,
    required pw.Font fontBold,
    required pw.Font fontSemi,
    required pw.Font fontItalic,
    pw.MemoryImage? vendorLogo,
    pw.MemoryImage? aorboLogo,
  }) {
    final isFlexible = policyType.toLowerCase() == 'flexible';

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divider, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: const pw.EdgeInsets.all(18),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Date of Booking : ',
                      style: pw.TextStyle(
                        font: fontSemi,
                        fontSize: 9,
                        color: _brand,
                      ),
                    ),
                    pw.TextSpan(
                      text: DateFormat(
                        'dd/MM/yyyy hh:mm a',
                      ).format(_bookingDate),
                      style: pw.TextStyle(
                        font: fontSemi,
                        fontSize: 9,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Status:  ',
                      style: pw.TextStyle(
                        font: fontSemi,
                        fontSize: 9,
                        color: _ink,
                      ),
                    ),
                    pw.TextSpan(
                      text: _bookingStatus,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 9,
                        color: _green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // VENDOR HEADER
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 56,
                height: 56,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: vendorLogo != null
                    ? pw.ClipRRect(
                        horizontalRadius: 8,
                        verticalRadius: 8,
                        child: pw.Image(vendorLogo, fit: pw.BoxFit.cover),
                      )
                    : pw.Container(
                        decoration: pw.BoxDecoration(
                          color: _chipBg,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          _vendorName.substring(0, 1).toUpperCase(),
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 22,
                            color: _ink,
                          ),
                        ),
                      ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      _vendorName.toUpperCase(),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 13,
                        color: _ink,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _vendorAddress,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 8,
                        color: _inkMid,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'For Assistance  ',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 8,
                            color: _inkMid,
                          ),
                        ),
                        pw.Text(
                          _vendorPhone,
                          style: pw.TextStyle(
                            font: fontSemi,
                            fontSize: 8,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Email : $_vendorEmail',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 8,
                        color: _inkMid,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Container(
                width: 64,
                height: 36,
                decoration: pw.BoxDecoration(
                  color: _aorboYellow,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                alignment: pw.Alignment.center,
                child: aorboLogo != null
                    ? pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Image(aorboLogo, fit: pw.BoxFit.contain),
                      )
                    : pw.Text(
                        'AORBO\nTREKS',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 8,
                          color: _ink,
                        ),
                      ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // TREK TITLE BANNER
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _yellowBg,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _trekTitle,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 14,
                          color: _green,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _trekDescription,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: _inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _idRow('Ticket ID', _bookingNumber, fontSemi, fontBold),
                    pw.SizedBox(height: 3),
                    _idRow('TBR ID', _tbrId, fontSemi, fontBold),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 4),

          // DEPARTURE / DAYS / ARRIVAL
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: const pw.BoxDecoration(color: _yellowBg),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${DateFormat('E, dd MMM').format(_startDate)}   ${DateFormat('hh:mm a').format(_startDate)}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: _ink,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _vendorCity,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: _inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _chipBg,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        _trekDuration
                            .replaceAll('Days', 'D')
                            .replaceAll('Nights', 'N'),
                        style: pw.TextStyle(
                          font: fontSemi,
                          fontSize: 8,
                          color: _inkMid,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 4,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '${DateFormat('E, dd MMM').format(_endDate)}   ${DateFormat('hh:mm a').format(_endDate)}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: _ink,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _vendorCity,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 8,
                          color: _inkMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // TREK + TRAVELLER DETAILS
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('TREK DETAILS', fontBold),
                    pw.SizedBox(height: 6),
                    _kvRow('Trek Name', _trekTitle, font, fontSemi),
                    _kvRow('Trek Operator', _vendorName, font, fontSemi),
                    _kvRow('Boarding Point', _boardingPoint, font, fontSemi),
                    _kvRow('Trek Captain', _captainName, font, fontSemi),
                    _kvRow('Captain Contact', _captainPhone, font, fontSemi),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('TRAVELLER DETAILS', fontBold),
                    pw.SizedBox(height: 6),
                    _travellersTable(font, fontSemi, fontBold),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Total NO of Slots: ${_travelers.length}',
                      style: pw.TextStyle(
                        font: fontSemi,
                        fontSize: 8,
                        color: _brand,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          _sectionTitle('PAYMENT DETAILS', fontBold),
          pw.SizedBox(height: 6),
          _paymentTable(
            isFlexible: isFlexible,
            font: font,
            fontSemi: fontSemi,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 14),
          pw.Container(height: 0.6, color: _ink),
          pw.SizedBox(height: 12),

          pw.Text(
            'CANCELLATION POLICY:',
            style: pw.TextStyle(font: fontBold, fontSize: 11, color: _ink),
          ),
          pw.SizedBox(height: 8),
          _cancellationPolicyTable(
            isFlexible: isFlexible,
            font: font,
            fontSemi: fontSemi,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 12),
          if (isFlexible) ...[
            _policyNote(
              'GST and taxes are non-refundable. The advance secures your slot and is non-refundable upon cancellation.',
              font,
            ),
            _policyNote(
              'The remaining balance will be refunded within 5 to 7 working days, subject to cancellation terms.',
              font,
            ),
            _policyNote(
              'The cancellation policy will be solely determined and approved by the respective vendor.',
              font,
            ),
            _policyNote(
              'For group bookings, individual slots may be cancelled.',
              font,
            ),
          ] else ...[
            _policyNote(
              'Cancellation fees are applied on a per-slot basis. The cancellation charge mentioned above is calculated based on a seat fare of ₹$_finalAmount.',
              font,
            ),
          ],
          pw.SizedBox(height: 14),
          pw.Center(
            child: pw.Text(
              'Service start time: ${DateFormat('HH:mm').format(_startDate)}',
              style: pw.TextStyle(font: fontBold, fontSize: 9, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────
  static pw.Widget _idRow(
    String label,
    String value,
    pw.Font fontSemi,
    pw.Font fontBold,
  ) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          '$label : ',
          style: pw.TextStyle(font: fontSemi, fontSize: 8, color: _brand),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: fontBold, fontSize: 8, color: _ink),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 0.5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: fontBold, fontSize: 10, color: _ink),
      ),
    );
  }

  static pw.Widget _kvRow(
    String key,
    String value,
    pw.Font font,
    pw.Font fontSemi,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              key,
              style: pw.TextStyle(font: font, fontSize: 8, color: _inkMid),
            ),
          ),
          pw.Expanded(
            flex: 6,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(font: fontSemi, fontSize: 8, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _travellersTable(
    pw.Font font,
    pw.Font fontSemi,
    pw.Font fontBold,
  ) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(5),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          children: [
            _tableHeader('Name', fontSemi),
            _tableHeader('Age', fontSemi),
            _tableHeader('Gender', fontSemi),
          ],
        ),
        ..._travelers.map(
          (t) => pw.TableRow(
            children: [
              _tableCell(t['name'] ?? '-', fontSemi),
              _tableCell(t['age'] ?? '-', font),
              _tableCell(t['gender'] ?? '-', font),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8, color: _inkMid),
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8, color: _ink),
      ),
    );
  }

  static pw.Widget _paymentTable({
    required bool isFlexible,
    required pw.Font font,
    required pw.Font fontSemi,
    required pw.Font fontBold,
  }) {
    final isFullyPaid = _paymentStatus == 'full_paid';
    final statusText = isFullyPaid
        ? 'Paid'
        : _paymentStatus == 'partial_paid'
        ? 'Partially Paid'
        : 'Pending';
    final statusColor = isFullyPaid ? _green : _red;

    return pw.Column(
      children: [
        _payRow('Base Fare', '₹$_baseFare', font, fontSemi),
        _payRow('Traveller Insurance', '₹$_insurance', font, fontSemi),
        _payRow('Operator GST', '₹$_gst', font, fontSemi),
        _payRow('Coupon', '- ₹$_discount', font, fontSemi),
        _payRow('Total Amount', '₹$_finalAmount', font, fontBold),
        _payRow('Status', statusText, font, fontBold, valueColor: statusColor),
        if (isFlexible) ...[
          _payRow('Amount Paid', '₹$_paidAmount', font, fontSemi),
          _payRow('Amount to be Paid', '₹$_pendingAmount', font, fontSemi),
        ],
      ],
    );
  }

  static pw.Widget _payRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold, {
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 8.5, color: _ink),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 8.5,
              color: valueColor ?? _ink,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _cancellationPolicyTable({
    required bool isFlexible,
    required pw.Font font,
    required pw.Font fontSemi,
    required pw.Font fontBold,
  }) {
    final fare = double.tryParse(_finalAmount) ?? 5999;

    if (isFlexible) {
      return pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(5),
          1: pw.FlexColumnWidth(4),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 0.5)),
            ),
            children: [
              _policyHead('Before departure', fontBold),
              _policyHead('Deduction', fontBold),
            ],
          ),
          _policyRow(
            'Advance Payment (₹999)',
            'Non-refundable',
            font,
            fontSemi,
          ),
          _policyRow(
            'Full Payment Mode',
            '₹999 held, refund processed',
            font,
            fontSemi,
          ),
          _policyRow(
            'Cancellation Notice',
            '1 day before trek',
            font,
            fontSemi,
          ),
        ],
      );
    }

    final d3Before = _startDate.subtract(const Duration(days: 3));
    final d1Before12pm = _startDate.subtract(const Duration(days: 1));
    final dayOf = _startDate;

    final r1 = (fare * 0.20).round();
    final r2 = (fare * 0.50).round();
    final r3 = (fare * 0.70).round();
    final r4 = fare.round();

    final fmt = DateFormat('EEE, dd MMM');

    return pw.Table(
      columnWidths: const {0: pw.FlexColumnWidth(5), 1: pw.FlexColumnWidth(3)},
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 0.5)),
          ),
          children: [
            _policyHead('Before departure', fontBold),
            _policyHead('Deduction', fontBold),
          ],
        ),
        _policyRow(
          'Cancelled before ${fmt.format(d3Before)} 12:00PM',
          '20% (₹$r1)',
          font,
          fontSemi,
        ),
        _policyRow(
          'From ${fmt.format(d3Before)} 12:00 PM to ${fmt.format(d1Before12pm)} 11:59 AM',
          '50% (₹$r2)',
          font,
          fontSemi,
        ),
        _policyRow(
          'From ${fmt.format(d1Before12pm)} 12:00 PM to ${fmt.format(dayOf)} 11:00 AM',
          '70% (₹$r3)',
          font,
          fontSemi,
        ),
        _policyRow(
          'No refund after ${fmt.format(dayOf)} 11:00 AM',
          '100% (₹$r4)',
          font,
          fontSemi,
        ),
      ],
    );
  }

  static pw.Widget _policyHead(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9, color: _ink),
      ),
    );
  }

  static pw.TableRow _policyRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontSemi,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 8, color: _ink),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(font: fontSemi, fontSize: 8, color: _ink),
          ),
        ),
      ],
    );
  }

  static pw.Widget _policyNote(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '★ ',
            style: pw.TextStyle(font: font, fontSize: 8, color: _ink),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: font, fontSize: 7.5, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DISCLAIMER
  // ─────────────────────────────────────────────
  static pw.Widget _buildDisclaimer({
    required pw.Font fontBold,
    required pw.Font fontSemi,
  }) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divider, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DISCLAIMER:',
            style: pw.TextStyle(font: fontBold, fontSize: 12, color: _ink),
          ),
          pw.SizedBox(height: 10),
          _discHead('Mandatory User Requirement:', fontBold),
          _discBody(
            'Users must carry a valid government-issued photo ID. Vendors may request verification at any time. Refusal or fraud may result in denial of participation without refund.',
          ),
          pw.SizedBox(height: 8),
          _discHead('What We Are Responsible For:', fontBold),
          _discBullet(
            'Providing a platform to connect users with verified trek organizers (Vendors).',
          ),
          _discBullet('Conducting basic vendor verification before listing.'),
          _discBullet('Offering a secure system for booking and payment.'),
          _discBullet(
            'First-level customer support and limited emergency coordination (where applicable).',
          ),
          pw.SizedBox(height: 8),
          _discHead('What We Are Not Responsible For:', fontBold),
          _discBullet(
            'Vendor actions, misconduct, or service quality during treks.',
          ),
          _discBullet(
            'Cancellations, delays, or changes by vendors due to weather, low bookings, or emergencies.',
          ),
          _discBullet(
            'Injury, health issues, or property loss during treks. Users\' personal fitness or health conditions.',
          ),
          _discBullet(
            'Any disputes or refund claims between users and vendors.',
          ),
          _discBullet(
            'External services like transport, accommodation, or insurance.',
          ),
          pw.SizedBox(height: 8),
          _discHead('Indemnity:', fontBold),
          _discBody(
            'Users agree to indemnify Aorbo Treks against any claims, damages, or disputes arising from their actions, use of the platform, or engagement with vendors.',
          ),
          pw.SizedBox(height: 8),
          _discHead('Governing Law:', fontBold),
          _discBody(
            'All matters are governed by Indian law and subject to courts in [Insert Jurisdiction, e.g., Hyderabad, Telangana].',
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'By proceeding, users confirm acceptance of this disclaimer and its terms.',
            style: const pw.TextStyle(fontSize: 8, color: _ink),
          ),
        ],
      ),
    );
  }

  static pw.Widget _discHead(String text, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: fontBold, fontSize: 9, color: _ink),
      ),
    );
  }

  static pw.Widget _discBody(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8, color: _ink, lineSpacing: 2),
      ),
    );
  }

  static pw.Widget _discBullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2, left: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: const pw.TextStyle(fontSize: 8, color: _ink)),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 8,
                color: _ink,
                lineSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

// The invoice generator used PdfGoogleFonts.poppins*() — four files downloaded from
// fonts.gstatic.com on EVERY invoice — so a weak/offline connection made invoice
// generation fail (same failure class as the google_fonts crash reported from real
// phones). It now loads Poppins from the app bundle. These tests prove the four
// faces are bundled and usable to build a PDF with NO network, and guard against
// the network loader coming back.

const _faces = [
  'Poppins-Regular.ttf',
  'Poppins-Bold.ttf',
  'Poppins-SemiBold.ttf',
  'Poppins-Italic.ttf',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all four Poppins faces the invoice needs are bundled and parse as fonts', () async {
    for (final f in _faces) {
      final data = await rootBundle.load('assets/fonts/poppins/$f');
      expect(data.lengthInBytes, greaterThan(10000), reason: '$f should be a real font file');
      // pdf parses the TrueType tables on construction — throws on a corrupt file
      pw.Font.ttf(data);
    }
  });

  test('a PDF renders from the bundled fonts with no network access', () async {
    Future<pw.Font> load(String f) async => pw.Font.ttf(await rootBundle.load('assets/fonts/poppins/$f'));
    final regular = await load('Poppins-Regular.ttf');
    final bold = await load('Poppins-Bold.ttf');
    final semi = await load('Poppins-SemiBold.ttf');
    final italic = await load('Poppins-Italic.ttf');

    final doc = pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold, italic: italic));
    doc.addPage(pw.Page(
      build: (_) => pw.Column(children: [
        pw.Text('Aorbo Treks Invoice'),
        pw.Text('Semi bold line', style: pw.TextStyle(font: semi)),
        pw.Text('Bold line', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Italic line', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
      ]),
    ));
    final bytes = await doc.save();

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('the invoice service no longer downloads fonts (guards against a regression)', () {
    final src = File('lib/services/invoice_pdf_service.dart').readAsStringSync();
    expect(src.contains('PdfGoogleFonts'), isFalse);
    for (final f in _faces) {
      expect(src.contains(f), isTrue, reason: 'invoice should load $f from the bundle');
    }
  });
}

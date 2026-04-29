// ─────────────────────────────────────────────────────────────────────────────
// invoice_example_screen.dart
// AORBO TREKS — Example screen showing all 3 invoice templates
// ⚠️  FOR DEVELOPMENT / PREVIEW ONLY — replace with real API call
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../models/invoice/mock_invoice_data.dart';
import '../widgets/invoice_widget.dart';



class InvoiceExampleScreen extends StatefulWidget {
  const InvoiceExampleScreen({super.key});

  @override
  State<InvoiceExampleScreen> createState() => _InvoiceExampleScreenState();
}

class _InvoiceExampleScreenState extends State<InvoiceExampleScreen> {
  int _selectedTemplate = 0;

  final _templates = [
    ('Standard — Full Paid', MockInvoiceData.standardFullPaid),
    ('Flexible — Full Paid', MockInvoiceData.flexibleFullPaid),
    ('Flexible — Advance Paid', MockInvoiceData.flexibleAdvancePaid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      appBar: AppBar(
        title: const Text('AORBO Invoice Preview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: List.generate(_templates.length, (i) {
                final selected = i == _selectedTemplate;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTemplate = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.black87
                            : Colors.white,
                        border: Border.all(
                          color: selected
                              ? Colors.black87
                              : const Color(0xFFD3D1C7),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _templates[i].$1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: InvoiceWidget(
        invoice: _templates[_selectedTemplate].$2,
      ),
    );
  }
}

// ── Entry point (for isolated testing) ───────────────────────────────────────

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InvoiceExampleScreen(),
  ));
}

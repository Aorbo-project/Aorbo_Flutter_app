// ─────────────────────────────────────────────────────────────────────────────
// disclaimer_widget.dart
// AORBO TREKS — Disclaimer Section (Right Page)
// Fully dynamic — all content from API
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../models/invoice/invoice_model.dart';

class DisclaimerWidget extends StatelessWidget {
  final DisclaimerData disclaimer;

  const DisclaimerWidget({super.key, required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title
        const Text(
          'DISCLAIMER:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 14),

        // ── Dynamic sections
        ...disclaimer.sections.map((section) => _buildSection(section)),

        const SizedBox(height: 12),

        // ── Closing statement
        Text(
          disclaimer.closingStatement,
          style: const TextStyle(
            fontSize: 11.5,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(DisclaimerSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Paragraph (if any)
          if (section.paragraph != null)
            Text(
              section.paragraph!,
              style: const TextStyle(fontSize: 11.5, height: 1.5),
            ),

          // Bullets (if any)
          if (section.bullets != null)
            ...section.bullets!.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(top: 3, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•  ',
                      style: TextStyle(fontSize: 11.5, height: 1.5),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style:
                            const TextStyle(fontSize: 11.5, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

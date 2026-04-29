// ─────────────────────────────────────────────────────────────────────────────
// payment_details_widget.dart
// AORBO TREKS — Payment Details Section
// Renders correctly for all 3 invoice templates
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../models/invoice/invoice_model.dart';

class PaymentDetailsWidget extends StatelessWidget {
  final PaymentDetails payment;
  final InvoiceTemplate template;

  const PaymentDetailsWidget({
    super.key,
    required this.payment,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section title
        Row(
          children: const [
            Icon(Icons.receipt_long_outlined, size: 16),
            SizedBox(width: 6),
            Text(
              'PAYMENT DETAILS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Base Fare (mandatory — all templates)
        _buildRow('Base Fare', _fmt(payment.baseFare)),

        // ── Coupon Discount (optional)
        if (payment.couponDiscount != null && payment.couponDiscount! > 0)
          _buildRow(
            'Coupon Discount',
            '- ${_fmt(payment.couponDiscount!)}',
            valueColor: const Color(0xFF1D9E75),
          ),

        // ── Final Base Fare (mandatory — all templates)
        _buildRow(
          'Final Base Fare',
          _fmt(payment.finalBaseFare),
          isBold: true,
        ),

        // ── Standard policy only add-ons
        if (template == InvoiceTemplate.standardFullPaid) ...[
          if (payment.freeCancellation != null) ...[
            _buildRow(
              'Free Cancellation',
              _fmt(payment.freeCancellation!.amount),
            ),
            _buildPolicyIdRow(payment.freeCancellation!.policyId),
          ],
          if (payment.travelInsurance != null) ...[
            _buildRow(
              'Travel Insurance',
              _fmt(payment.travelInsurance!.amount),
            ),
            _buildPolicyIdRow(payment.travelInsurance!.policyId),
          ],
        ],

        // ── GST (mandatory — all templates)
        _buildRow(
          'GST (${_pct(payment.gstRate)}%)',
          _fmt(payment.gstAmount),
        ),

        // ── Platform Fee (mandatory — all templates)
        _buildRow('Platform Fee', _fmt(payment.platformFee)),

        // ── Divider before totals
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 1, thickness: 0.5),
        ),

        // ── Total Amount (mandatory — all templates)
        _buildRow(
          'Total Amount',
          _fmt(payment.totalAmount),
          isBold: true,
        ),

        const SizedBox(height: 6),

        // ── Status badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 13),
            ),
            _StatusBadge(status: payment.status),
          ],
        ),

        // ── Template 3 only: Trek Advance + Balance Due
        if (template == InvoiceTemplate.flexibleAdvancePaid) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 8),
          _buildRow(
            'Trek Advance',
            _fmt(payment.trekAdvanceAmount ?? 0),
            isBold: true,
            valueColor: const Color(0xFF1D9E75),
          ),
          _buildRow(
            'Balance Due',
            _fmt(payment.balanceDue ?? 0),
            isBold: true,
            valueColor: const Color(0xFFBA7517),
          ),
        ],
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyIdRow(String policyId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 2),
      child: Text(
        'Policy ID: $policyId',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF888780),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _fmt(double amount) {
    // Format as ₹ with comma separation
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '₹ $formatted';
  }

  String _pct(double rate) => (rate * 100).toStringAsFixed(0);
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final InvoiceStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case InvoiceStatus.paid:
        bg = const Color(0xFFEAF3DE);
        fg = const Color(0xFF3B6D11);
        label = 'Paid';
        break;
      case InvoiceStatus.partiallyPaid:
        bg = const Color(0xFFFAEEDA);
        fg = const Color(0xFF854F0B);
        label = 'Partially Paid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

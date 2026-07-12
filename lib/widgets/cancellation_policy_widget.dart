// cancellation_policy_widget.dart

import 'package:arobo_app/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../freezed_models/treks/trek_detail_model.dart';

class CancellationPolicyWidget extends StatelessWidget {
  final String? departureDate;
  final CancellationPolicy? policy;
  // Real trek/booking price — needed to compute the rupee amount per slab.
  // Falls back to 0 (shows "₹0" rows) if not supplied, same as the React
  // vendor preview does when a price hasn't been entered yet.
  final String? basePrice;

  const CancellationPolicyWidget({
    super.key,
    required this.policy,
    required this.departureDate,
    this.basePrice,
  });

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          Text(
            policy?.title ?? "",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),

          const SizedBox(height: 12),

          // ── Table header
          _buildTableHeader(),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 4),

          // ── Policy rows — computed from policy.settings (the live,
          // admin-editable numbers), not the static policy.rules text.
          ...rows.map((row) => _buildPolicyRow(row)),

          const SizedBox(height: 16),

          // ── Footnotes
          ...(policy?.descriptionPoints ?? [])
              .map((note) => _buildFootnote(note)),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  double get _price => double.tryParse(basePrice ?? '') ?? 0;

  DateTime? get _departure {
    if (departureDate == null || departureDate!.isEmpty) return null;
    return DateTime.tryParse(departureDate!);
  }

  String _cutoffLabel(int hoursBefore) {
    final d = _departure;
    if (d == null) return '$hoursBefore+ hours before departure';
    return AuthUtils.formatDateTimeWithHourDecrease(
      d.toIso8601String(),
      hoursBefore,
    );
  }

  String _amount(num pct) {
    final amount = (_price * pct / 100).round();
    return NumberFormat('#,##0', 'en_IN').format(amount);
  }

  // Builds the exact rows to render from policy.settings (live admin-set
  // percentages — see Backend utils/cancellationPolicyLive.js) plus the real
  // price and departure date, mirroring the React vendor preview
  // (PoliciesSection.jsx) so both surfaces show the same honest numbers.
  List<_PolicyPreviewRow> _buildRows() {
    final settings = policy?.settings;
    if (settings == null) return [];

    if (policy?.policyType == 'flexible') {
      final advanceAmount = settings['advanceAmount'] ?? 999;
      final advanceNonRefundable = settings['advanceNonRefundable'] ?? true;
      final fullPayment24hDeductionPct =
          settings['fullPayment24hDeductionPct'] ?? 100;
      return [
        _PolicyPreviewRow(
          'Advance Payment (₹$advanceAmount)',
          advanceNonRefundable == true ? 'Non-refundable' : 'Refundable',
        ),
        _PolicyPreviewRow(
          'Full Payment, cancelled more than 24h before departure',
          '₹$advanceAmount forfeited, rest refunded',
        ),
        _PolicyPreviewRow(
          'Cancellation within 24 hours of departure',
          '$fullPayment24hDeductionPct% (₹${_amount(fullPayment24hDeductionPct)})',
        ),
      ];
    }

    final slab72 = settings['slab72hPlusPct'] ?? 20;
    final slab48 = settings['slab48to72hPct'] ?? 50;
    final slab24 = settings['slab24to48hPct'] ?? 70;
    final slabUnder24 = settings['slabUnder24hPct'] ?? 100;
    return [
      _PolicyPreviewRow(
        'Cancelled before ${_cutoffLabel(72)}',
        '$slab72% (₹${_amount(slab72)})',
      ),
      _PolicyPreviewRow(
        'From ${_cutoffLabel(72)} to ${_cutoffLabel(48)}',
        '$slab48% (₹${_amount(slab48)})',
      ),
      _PolicyPreviewRow(
        'From ${_cutoffLabel(48)} to ${_cutoffLabel(24)}',
        '$slab24% (₹${_amount(slab24)})',
      ),
      _PolicyPreviewRow(
        'No refund after ${_cutoffLabel(24)}',
        '$slabUnder24% (₹${_amount(slabUnder24)})',
      ),
    ];
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: const [
          Expanded(
            flex: 6,
            child: Text(
              'Before departure',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Deduction',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(_PolicyPreviewRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              row.label,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFootnote(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '★  ',
            style: TextStyle(fontSize: 10, color: Color(0xFF888780)),
          ),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF888780),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyPreviewRow {
  final String label;
  final String value;
  const _PolicyPreviewRow(this.label, this.value);
}

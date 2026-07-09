// cancellation_policy_widget.dart

import 'package:arobo_app/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import '../freezed_models/treks/trek_detail_model.dart';

class CancellationPolicyWidget extends StatelessWidget {
  final String? departureDate;
  final CancellationPolicy? policy;

  const CancellationPolicyWidget({super.key, required this.policy,required this.departureDate});

  // BUGFIX: Rules.hours is typed `dynamic` (the API can omit it entirely),
  // so a null value passed `row.hours != 0` unharmed (null != 0 is true in
  // Dart) and was then handed straight to
  // AuthUtils.formatDateTimeWithHourDecrease's non-nullable `int` parameter,
  // throwing "type 'Null' is not a subtype of type 'int'" at the call site
  // and taking down the whole cancellation policy section.
  int? _hoursAsInt(dynamic hours) {
    if (hours == null) return null;
    if (hours is int) return hours;
    if (hours is num) return hours.toInt();
    return int.tryParse(hours.toString());
  }

  @override
  Widget build(BuildContext context) {
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

          // ── Policy rows
          ...(policy?.rules ?? []).map((row) => _buildPolicyRow(row)),

          const SizedBox(height: 16),

          // ── Footnotes
          ...(policy?.descriptionPoints ?? [])
              .map((note) => _buildFootnote(note)),

          const SizedBox(height: 8),
        ],
      ),
    );
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

  Widget _buildPolicyRow(Rules row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  row.rule ?? "",
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text(
                  row.deductionType == "fixed" ? "₹${row.deduction}" : "${row.deduction}%",
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
          if(_hoursAsInt(row.hours) != null && _hoursAsInt(row.hours) != 0) Text(
            "Before ${AuthUtils.formatDateTimeWithHourDecrease(departureDate ?? "", _hoursAsInt(row.hours)!)}",
            style: const TextStyle(fontSize: 12, height: 1.4),
          )
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
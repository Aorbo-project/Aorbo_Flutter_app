import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';

/// ─────────────────────────────────────────────
/// SAFE DATE PARSER – handles multiple formats
/// ─────────────────────────────────────────────
DateTime? _parseDateTimeSafe(String dateStr) {
  final value = dateStr.trim();
  if (value.isEmpty) return null;

  // 1) Strict ISO 8601 (with or without timezone)
  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {}

  // 2) "yyyy-MM-dd hh:mm a" (e.g., 2026-05-09 12:00 PM)
  try {
    return DateFormat('yyyy-MM-dd hh:mm a').parse(value).toLocal();
  } catch (_) {}

  // 3) "yyyy-MM-dd HH:mm" (24-hour format)
  try {
    return DateFormat('yyyy-MM-dd HH:mm').parse(value).toLocal();
  } catch (_) {}

  // 4) Space-separated fallback: add 'T' and assume local time
  try {
    return DateTime.parse(value.replaceFirst(' ', 'T')).toLocal();
  } catch (_) {}

  // 5) Date only
  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {}

  return null;
}

/// ─────────────────────────────────────────────
/// POLICY TYPES
/// ─────────────────────────────────────────────
enum PolicyType { standard, flexible, custom }

PolicyType _policyTypeFromString(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'standard':
      return PolicyType.standard;
    case 'flexible':
      return PolicyType.flexible;
    default:
      return PolicyType.custom;
  }
}

String _policyTypeLabel(PolicyType type) {
  switch (type) {
    case PolicyType.standard:
      return 'Standard';
    case PolicyType.flexible:
      return 'Flexible';
    case PolicyType.custom:
      return 'Custom';
  }
}

/// ─────────────────────────────────────────────
/// PUBLIC MODEL – backend compatible
/// ─────────────────────────────────────────────
class CancellationSlabModel {
  final String label;
  final int percent;
  final int amount;
  final bool isNoRefund;
  final String? code;

  const CancellationSlabModel({
    required this.label,
    required this.percent,
    required this.amount,
    this.isNoRefund = false,
    this.code,
  });

  factory CancellationSlabModel.fromJson(Map<String, dynamic> json) {
    return CancellationSlabModel(
      label: (json['label'] ?? '').toString(),
      percent: (json['percent'] is num)
          ? (json['percent'] as num).round()
          : int.tryParse('${json['percent']}') ?? 0,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).round()
          : int.tryParse('${json['amount']}') ?? 0,
      isNoRefund: json['is_no_refund'] == true || json['isNoRefund'] == true,
      code: json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'percent': percent,
        'amount': amount,
        'is_no_refund': isNoRefund,
        if (code != null) 'code': code,
      };
}

class CancellationPolicyModel {
  final PolicyType policyType;
  final String policyVersion;
  final List<CancellationSlabModel> slabs;
  final String? currencySymbol;

  const CancellationPolicyModel({
    required this.policyType,
    required this.policyVersion,
    required this.slabs,
    this.currencySymbol,
  });

  bool get isValid => slabs.isNotEmpty;

  factory CancellationPolicyModel.fromJson(Map<String, dynamic> json) {
    final rawSlabs = (json['slabs'] as List?) ?? const [];
    return CancellationPolicyModel(
      policyType: _policyTypeFromString(json['policy_type']?.toString()),
      policyVersion: (json['policy_version'] ?? 'v1').toString(),
      slabs: rawSlabs
          .whereType<Map>()
          .map((e) => CancellationSlabModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
      currencySymbol: json['currency_symbol']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'policy_type': _policyTypeLabel(policyType).toLowerCase(),
        'policy_version': policyVersion,
        'slabs': slabs.map((e) => e.toJson()).toList(),
        if (currencySymbol != null) 'currency_symbol': currencySymbol,
      };
}

/// ─────────────────────────────────────────────
/// ENGINE – pure calculation, no UI
/// ─────────────────────────────────────────────
class CancellationPolicyEngine {
  static String formatCutoff(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final hour = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;

    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';

    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} $hour:$minute $period';
  }

  static int deductionAmount(double basePrice, int pct) {
    return (basePrice * pct / 100).round();
  }

  static List<CancellationSlabModel> buildStandard(
    DateTime dep,
    double basePrice, {
    String? currencySymbol,
  }) {
    final cut72 = dep.subtract(const Duration(hours: 72));
    final cut48 = dep.subtract(const Duration(hours: 48));
    final cut24 = dep.subtract(const Duration(hours: 24));
    final cut4 = dep.subtract(const Duration(hours: 4));

    return [
      CancellationSlabModel(
        label: 'Cancelled before ${formatCutoff(cut72)}',
        percent: 20,
        amount: deductionAmount(basePrice, 20),
      ),
      CancellationSlabModel(
        label: 'From ${formatCutoff(cut72)}\nto ${formatCutoff(cut48)}',
        percent: 50,
        amount: deductionAmount(basePrice, 50),
      ),
      CancellationSlabModel(
        label: 'From ${formatCutoff(cut48)}\nto ${formatCutoff(cut24)}',
        percent: 70,
        amount: deductionAmount(basePrice, 70),
      ),
      CancellationSlabModel(
        label: 'No refund after\n${formatCutoff(cut4)}',
        percent: 100,
        amount: deductionAmount(basePrice, 100),
        isNoRefund: true,
      ),
    ];
  }

  static List<CancellationSlabModel> buildFlexible(
    DateTime dep,
    double basePrice, {
    double advanceAmount = 999,
    String? currencySymbol,
  }) {
    final cut24 = dep.subtract(const Duration(hours: 24));
    final cut4 = dep.subtract(const Duration(hours: 4));

    return [
      CancellationSlabModel(
        label: 'Advance amount is non-refundable at any time',
        percent: 100,
        amount: advanceAmount.round(),
        isNoRefund: true,
      ),
      CancellationSlabModel(
        label: 'Full payment — cancel before\n${formatCutoff(cut24)}',
        percent: 0,
        amount: 0,
      ),
      CancellationSlabModel(
        label: 'No refund after\n${formatCutoff(cut4)}',
        percent: 100,
        amount: basePrice.round(),
        isNoRefund: true,
      ),
    ];
  }
}

/// ─────────────────────────────────────────────
/// WIDGET
/// Keeps the old API working, but now supports:
/// - backendSlabs
/// - policyData
/// - policyVersion
/// - advanceAmount override
/// ─────────────────────────────────────────────
class CancellationPolicyCard extends StatelessWidget {
  final String? departureDate; // batchInfo?.startDate
  final String? basePrice;     // trekDetailData.value.basePrice
  final String? bookingType;   // trekDetailData.value.bookingType

  /// Optional override from backend or parent layer.
  final CancellationPolicyModel? policyData;

  /// Optional direct slabs if you already have a backend response mapped.
  final List<CancellationSlabModel>? backendSlabs;

  /// Optional: lets flexible policy show a different advance amount.
  final double advanceAmount;

  /// Optional: display-only version badge.
  final String? policyVersion;

  const CancellationPolicyCard({
    super.key,
    required this.departureDate,
    required this.basePrice,
    required this.bookingType,
    this.policyData,
    this.backendSlabs,
    this.advanceAmount = 999,
    this.policyVersion,
  });

  Color get _greyTextColor {
    try {
      return CommonColors.greyTextColor;
    } catch (_) {
      return const Color(0xFF757575);
    }
  }

  Color get _panelShadowColor {
    try {
      return CommonColors.blackColor;
    } catch (_) {
      return const Color(0xFF000000);
    }
  }

  String _currencyValue(int amount) {
    try {
      return NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(amount);
    } catch (_) {
      return '₹$amount';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (departureDate == null || basePrice == null) {
      return const SizedBox.shrink();
    }

    final dep = _parseDateTimeSafe(departureDate!);
    if (dep == null) return const SizedBox.shrink();

    final parsedPrice = double.tryParse(basePrice!.trim());
    if (parsedPrice == null) return const SizedBox.shrink();

    final resolvedType = policyData?.policyType ??
        _policyTypeFromString(bookingType?.toLowerCase());

    final resolvedPolicyVersion =
        policyData?.policyVersion ?? policyVersion ?? 'v1';

    final List<CancellationSlabModel> slabs =
        (policyData != null && policyData!.isValid)
            ? policyData!.slabs
            : (backendSlabs != null && backendSlabs!.isNotEmpty)
                ? backendSlabs!
                : (resolvedType == PolicyType.flexible)
                    ? CancellationPolicyEngine.buildFlexible(
                        dep,
                        parsedPrice,
                        advanceAmount: advanceAmount,
                      )
                    : CancellationPolicyEngine.buildStandard(
                        dep,
                        parsedPrice,
                      );

    if (slabs.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.8.w),
        boxShadow: [
          BoxShadow(
            color: _panelShadowColor.withValues(alpha: 0.10),
            blurRadius: 2.w,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row: title + version badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Cancellation Policy (${_policyTypeLabel(resolvedType)})',
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.trek_route_color,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    resolvedPolicyVersion,
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Column headers ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Before departure',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
                Text(
                  'Deduction',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blackColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Slab rows ──
            ...slabs.map(
              (slab) => _SlabRow(
                slab: slab,
                greyTextColor: _greyTextColor,
                currencyText: _currencyValue,
              ),
            ),
            const SizedBox(height: 12),

            // ── Footer note ──
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'GST & platform fees are non-refundable.',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlabRow extends StatelessWidget {
  final CancellationSlabModel slab;
  final Color greyTextColor;
  final String Function(int amount) currencyText;

  const _SlabRow({
    required this.slab,
    required this.greyTextColor,
    required this.currencyText,
  });

  Color get _color {
    if (slab.isNoRefund || slab.percent == 100) return const Color(0xFFC62828);
    if (slab.percent >= 70) return const Color(0xFFE65100);
    if (slab.percent >= 50) return const Color(0xFFF57F17);
    return const Color(0xFF2E7D32);
  }

  String get _badge {
    if (slab.isNoRefund || slab.percent == 100) {
      return 'No refund';
    }
    if (slab.percent == 0) {
      return '${currencyText(slab.amount)} deducted';
    }
    return '${slab.percent}% (${currencyText(slab.amount)})';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: slab.isNoRefund
                          ? const Color(0xFFC62828)
                          : CommonColors.trek_route_color,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    slab.label,
                    textScaler: const TextScaler.linear(1.0),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight:
                          slab.isNoRefund ? FontWeight.w600 : FontWeight.w500,
                      color: slab.isNoRefund
                          ? const Color(0xFFC62828)
                          : greyTextColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _color.withValues(alpha: 0.30)),
            ),
            child: Text(
              _badge,
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';

// ─────────────────────────────────────────────
// SAFE DATE PARSER – handles multiple formats
// ─────────────────────────────────────────────
DateTime? _parseDateTimeSafe(String dateStr) {
  // Try strict ISO 8601 (with 'T' and timezone)
  try {
    return DateTime.parse(dateStr).toLocal();
  } catch (_) {}
  // Try "yyyy-MM-dd hh:mm a" (e.g., 2026-05-09 12:00 PM)
  try {
    return DateFormat('yyyy-MM-dd hh:mm a').parse(dateStr).toLocal();
  } catch (_) {}
  // Try space-separated (no 'T', no timezone) – add 'T' and assume local
  try {
    return DateTime.parse(dateStr.replaceFirst(' ', 'T')).toLocal();
  } catch (_) {}
  // Try just date (if time missing)
  try {
    return DateTime.parse(dateStr).toLocal();
  } catch (_) {}
  return null;
}

// ─────────────────────────────────────────────
// ENGINE – pure calculation, no UI
// ─────────────────────────────────────────────
class CancellationPolicyEngine {
  static String formatCutoff(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${days[dt.weekday - 1]}, ${dt.day} '
        '${months[dt.month - 1]} $h:$m $period';
  }

  static int deductionAmount(double basePrice, int pct) =>
      (basePrice * pct / 100).round();

  static List<_Slab> buildStandard(DateTime dep, double basePrice) {
    final cut72 = dep.subtract(const Duration(hours: 72));
    final cut48 = dep.subtract(const Duration(hours: 48));
    final cut24 = dep.subtract(const Duration(hours: 24));
    final cut4 = dep.subtract(const Duration(hours: 4)); // ✅ DECLARED HERE

    return [
      _Slab(
          label: 'Cancelled before ${formatCutoff(cut72)}',
          pct: 20,
          amount: deductionAmount(basePrice, 20)),
      _Slab(
          label: 'From ${formatCutoff(cut72)}\nto ${formatCutoff(cut48)}',
          pct: 50,
          amount: deductionAmount(basePrice, 50)),
      _Slab(
          label: 'From ${formatCutoff(cut48)}\nto ${formatCutoff(cut24)}',
          pct: 70,
          amount: deductionAmount(basePrice, 70)),
      _Slab(
          label: 'No refund after\n${formatCutoff(cut4)}', // ✅ USES cut4
          pct: 100,
          amount: deductionAmount(basePrice, 100),
          isNoRefund: true),
    ];
  }

  static List<_Slab> buildFlexible(DateTime dep, double basePrice,
      {double advanceAmount = 999}) {
    final cut24 = dep.subtract(const Duration(hours: 24));
    final cut4 = dep.subtract(const Duration(hours: 4)); // ✅ DECLARED HERE

    return [
      _Slab(
          label: 'Advance only paid (any time)',
          pct: 100,
          amount: advanceAmount.round(),
          isNoRefund: true),
      _Slab(
          label: 'Full payment — cancel before\n${formatCutoff(cut24)}',
          pct: 0,
          amount: advanceAmount.round()),
      _Slab(
          label: 'No refund after\n${formatCutoff(cut4)}', // ✅ USES cut4
          pct: 100,
          amount: basePrice.round(),
          isNoRefund: true),
    ];
  }
}

class _Slab {
  final String label;
  final int pct;
  final int amount;
  final bool isNoRefund;
  const _Slab({
    required this.label,
    required this.pct,
    required this.amount,
    this.isNoRefund = false,
  });
}

// ── WIDGET ──
class CancellationPolicyCard extends StatelessWidget {
  final String? departureDate; // batchInfo?.startDate
  final String? basePrice; // trekDetailData.value.basePrice
  final String? bookingType; // trekDetailData.value.bookingType

  const CancellationPolicyCard({
    super.key,
    required this.departureDate,
    required this.basePrice,
    required this.bookingType,
  });

  // Fallback grey color if CommonColors.greyTextColor does not exist
  Color get _greyTextColor {
    try {
      return CommonColors.greyTextColor;
    } catch (_) {
      return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Parse & guard ──
    if (departureDate == null || basePrice == null) {
      return const SizedBox.shrink(); // silent fallback
    }

    final dep = _parseDateTimeSafe(departureDate!);
    if (dep == null) return const SizedBox.shrink();

    double? price;
    try {
      price = double.parse(basePrice!);
    } catch (_) {
      return const SizedBox.shrink();
    }

    final isFlexible = bookingType?.toLowerCase() == 'flexible';
    final slabs = isFlexible
        ? CancellationPolicyEngine.buildFlexible(dep, price)
        : CancellationPolicyEngine.buildStandard(dep, price);

    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(3.8.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.1),
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
            // Header
            Text(
              'Cancellation Policy (${isFlexible ? 'Flexible' : 'Standard'})',
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CommonColors.trek_route_color,
              ),
            ),
            const SizedBox(height: 16),

            // Column labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Before departure',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor),
                ),
                Text(
                  'Deduction',
                  textScaler: const TextScaler.linear(1.0),
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slabs
            ...slabs.map((slab) => _SlabRow(
                  slab: slab,
                  greyTextColor: _greyTextColor,
                )),

            const SizedBox(height: 12),

            // Footer note
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isFlexible
                    ? '₹999 advance is non-refundable. GST & platform fees are non-refundable.'
                    : 'GST & platform convenience fees are non-refundable on cancellation.',
                textScaler: const TextScaler.linear(1.0),
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: const Color(0xFF5D4037),
                  height: 1.5,
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
  final _Slab slab;
  final Color greyTextColor;

  const _SlabRow({
    required this.slab,
    required this.greyTextColor,
  });

  Color get _color {
    if (slab.isNoRefund || slab.pct == 100) return const Color(0xFFC62828);
    if (slab.pct >= 70) return const Color(0xFFE65100);
    if (slab.pct >= 50) return const Color(0xFFF57F17);
    return const Color(0xFF2E7D32);
  }

  String get _badge {
    if (slab.pct == 0) return '₹${slab.amount} deducted';
    return '${slab.pct}% (₹${slab.amount})';
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
              border: Border.all(color: _color.withValues(alpha: 0.3)),
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
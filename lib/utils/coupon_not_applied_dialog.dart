import 'package:arobo_app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'screen_constants.dart';

/// Why a coupon was not applied, as a popup the customer has to read and close
/// (owner, 6 Nov 2026: a customer tried a 6+ group coupon 9 times with fewer
/// travellers; a snackbar went by unnoticed and the card never said "6+").
/// Used for the card's own check (before any call) and for every refusal the
/// server sends back.

const Color _accent = Color(0xFFC9702E);
const Color _accentTint = Color(0x14C9702E);
const Color _ink = Color(0xFF1A1A2E);
const Color _inkSoft = Color(0xFF6B6B7B);

final RegExp _groupRefusal = RegExp(r'Minimum (\d+) participants required');

/// Plain words for a group coupon the booking is too small for.
String couponGroupReason(int min, int? travellers) {
  final base = 'This group offer needs at least $min travellers in one booking.';
  if (travellers == null || travellers <= 0 || travellers >= min) return base;
  final more = min - travellers;
  return '$base Your booking has $travellers. Add $more more traveller${more == 1 ? '' : 's'} to use it.';
}

/// The server's refusal in the customer's words; other reasons pass through as sent.
String couponRefusalText(String serverMessage, {int? travellers}) {
  final match = _groupRefusal.firstMatch(serverMessage);
  if (match != null) return couponGroupReason(int.parse(match.group(1)!), travellers);
  return serverMessage;
}

Future<void> showCouponNotAppliedDialog(
  BuildContext context, {
  required String reason,
  String? code,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: EdgeInsets.all(2.6.w),
        decoration: const BoxDecoration(color: _accentTint, shape: BoxShape.circle),
        child: Icon(Icons.local_offer_outlined, color: _accent, size: 6.w),
      ),
      title: Text(
        (code == null || code.trim().isEmpty) ? 'Coupon not applied' : '${code.trim()} not applied',
        textAlign: TextAlign.center,
        style: AppType.style(FontSize.s13, w: FontWeight.w700, color: _ink),
      ),
      content: Text(
        reason,
        key: const Key('coupon-not-applied-reason'),
        textAlign: TextAlign.center,
        style: AppType.style(FontSize.s10, color: _inkSoft, height: 1.5),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          style: TextButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.2.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('OK', style: AppType.style(FontSize.s10, w: FontWeight.w700, color: Colors.white)),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'screen_constants.dart';
import '../models/coupon_code/coupon_code_model.dart';
import 'auth_utils.dart';
import 'coupon_display_helper.dart';
import 'coupon_terms_sheet.dart';

/// Card for vendor-assigned (non-PLATFORM scope) coupons on the checkout
/// Coupon Code screen. Approved design: flat white card, thin gradient
/// accent bar on the left (Variant 3 — "Left Accent Bar"), muted terracotta
/// brand accent. Eligible coupons carry the accent in full; used/inactive/
/// expired coupons drop to a neutral grey "blocked" state instead of a
/// second color, matching the old legacy screen's bright-vs-blocked pattern.
class VendorCouponCard extends StatelessWidget {
  final CouponCardData? coupon;
  final VoidCallback onApply;
  final bool isApplied;

  const VendorCouponCard({
    super.key,
    required this.coupon,
    required this.onApply,
    this.isApplied = false,
  });

  static const Color _accentStart = Color(0xFFE8925A);
  static const Color _accentEnd = Color(0xFFF4C68A);
  static const Color _accentText = Color(0xFFC9702E);
  static const Color _accentTint = Color(0x14C9702E);
  static const Color _blocked = Color(0xFFACAFB8);
  static const Color _border = Color(0xFFECECF1);
  static const Color _neutralBg = Color(0xFFF7F8FA);
  static const Color _ink = Color(0xFF1A1A2E);
  static const Color _inkSoft = Color(0xFF6B6B7B);
  static const Color _labelSoft = Color(0xFF9A9AAE);

  bool get _isBlocked =>
      !(coupon?.isActive ?? false) ||
      (coupon?.isExpired ?? false) ||
      (coupon?.isUsed ?? false);

  String get _blockedReason {
    if (coupon?.isUsed ?? false) return 'Already used';
    if (coupon?.isExpired ?? false) return 'Expired';
    return 'Not available';
  }

  String get _headline =>
      coupon != null ? CouponDisplayHelper.headline(coupon!) : '';

  String? get _conditionText {
    if (coupon == null) return null;
    final parts = <String>[];
    final maxDiscount = double.tryParse(coupon!.maxDiscountAmount ?? '') ?? 0;
    if (coupon!.discountType != 'fixed' && maxDiscount > 0) {
      parts.add('Upto ${AuthUtils.formatPrice(coupon!.maxDiscountAmount!)}');
    }
    final minAmount = double.tryParse(coupon!.minAmount ?? '') ?? 0;
    if (minAmount > 0) {
      parts.add('On orders above ${AuthUtils.formatPrice(coupon!.minAmount!)}');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _isBlocked;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.6.h, left: 7.w, right: 7.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.w),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border, width: 1),
              ),
              padding: EdgeInsets.fromLTRB(5.8.w, 2.4.h, 4.5.w, 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      color: blocked ? _neutralBg : _accentTint,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'FOR THIS TREK',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: blocked ? _labelSoft : _accentText,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.3.h),
                  Text(
                    _headline,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: _ink,
                    ),
                  ),
                  if (_conditionText != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      _conditionText!,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        color: _inkSoft,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (blocked) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      _blockedReason,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s9,
                        color: _labelSoft,
                      ),
                    ),
                  ],
                  SizedBox(height: 1.8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
                        decoration: BoxDecoration(
                          color: _neutralBg,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: _border),
                        ),
                        child: Text(
                          coupon?.code ?? '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: FontSize.s9,
                            letterSpacing: 0.3,
                            color: blocked ? _inkSoft : _accentText,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => showCouponTermsSheet(context, coupon),
                            child: Text(
                              'T&C*',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w600,
                                color: blocked ? _labelSoft : _accentText,
                                decoration: TextDecoration.underline,
                                decorationColor: blocked ? _labelSoft : _accentText,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          if (blocked)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 0.9.h),
                              decoration: BoxDecoration(
                                color: _neutralBg,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: _border),
                              ),
                              child: Text(
                                'Used',
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w700,
                                  color: _inkSoft,
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: onApply,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 0.9.h),
                                decoration: BoxDecoration(
                                  color: _accentText,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  isApplied ? 'Applied' : 'Apply',
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 1.6.w,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: blocked ? [_blocked, _blocked] : [_accentStart, _accentEnd],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

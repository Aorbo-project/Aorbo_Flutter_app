import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'screen_constants.dart';
import '../models/coupon_code/coupon_code_model.dart';
import 'ist_date_utils.dart';

const Color _accentStart = Color(0xFFE8925A);
const Color _accentEnd = Color(0xFFF4C68A);
const Color _accentText = Color(0xFFC9702E);
const Color _border = Color(0xFFECECF1);
const Color _neutralBg = Color(0xFFF7F8FA);
const Color _ink = Color(0xFF1A1A2E);
const Color _inkSoft = Color(0xFF6B6B7B);

/// Shared T&C bottom sheet for any coupon card — vendor-assigned or
/// PLATFORM — so both use the same content rules and the same restyled
/// (terracotta accent, drag-handle) look instead of the old ticket-strip
/// sheet.
///
/// Sized to its own content (capped at 85% of screen height, scrollable
/// past that) rather than a fixed DraggableScrollableSheet fraction —
/// a short T&C list previously left a large empty gap below the card,
/// showing the scrim through it.
void showCouponTermsSheet(BuildContext context, CouponCardData? coupon) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: _CouponTermsSheetContent(coupon: coupon),
      ),
    ),
  );
}

class _CouponTermsSheetContent extends StatelessWidget {
  final CouponCardData? coupon;

  const _CouponTermsSheetContent({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final expiryLabel = ISTDateUtils.toIST(coupon?.validUntil) != null
        ? ISTDateUtils.formatDateTime(coupon?.validUntil)
        : null;

    final List<String> fallbackTerms = [
      'Applicable on selected treks only.',
      'Coupon code is valid for a single use per customer.',
      'Additional terms & conditions may apply.',
      if (expiryLabel != null) 'Offer expires on $expiryLabel.',
    ];

    final terms = (coupon?.termsAndConditions != null &&
            coupon!.termsAndConditions!.isNotEmpty)
        ? coupon!.termsAndConditions!
        : fallbackTerms;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(6.w, 1.6.h, 6.w, 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 9.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon?.code ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: _ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: _neutralBg,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Icon(Icons.close, size: 4.w, color: _inkSoft),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Terms & Conditions',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          SizedBox(height: 1.2.h),
          ...terms.map(
            (term) => Padding(
              padding: EdgeInsets.only(bottom: 1.2.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.8.h),
                    child: Container(
                      width: 1.4.w,
                      height: 1.4.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [_accentStart, _accentEnd]),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Text(
                      term,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s10,
                        color: _inkSoft,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (coupon?.howToApply != null && coupon!.howToApply!.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              'How To Apply',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              coupon!.howToApply!,
              style: GoogleFonts.poppins(fontSize: FontSize.s10, color: _inkSoft, height: 1.5),
            ),
          ],
          SizedBox(height: 1.6.h),
          Container(
            padding: EdgeInsets.only(top: 1.6.h),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Text(
              coupon?.footerNote?.isNotEmpty == true
                  ? coupon!.footerNote!
                  : 'Book now and start your adventure with Aorbo Treks!',
              style: GoogleFonts.poppins(
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w700,
                color: _accentText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

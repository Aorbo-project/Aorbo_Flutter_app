import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'common_colors.dart';
import 'screen_constants.dart';
import '../models/coupon_code/coupon_code_model.dart';
import 'ist_date_utils.dart';

class CouponCard extends StatefulWidget {
  final CouponCardData? coupon;
  final VoidCallback onApply;
  final bool isApplied;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.onApply,
    this.isApplied = false,
  });

  @override
  State<CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<CouponCard> {
  bool isExpanded = false;

  CouponCardData? get coupon => widget.coupon;
  VoidCallback get onApply => widget.onApply;
  bool get isApplied => widget.isApplied;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h, left: 8.w, right: 8.w),
      child: Container(
        width: 80.w,
        // No fixed height — card grows with description
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(color: const Color(0xffF0F0F0), width: 0.1.w),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left mint strip ──────────────────────────────────────────
              Container(
                width: 11.w,
                decoration: BoxDecoration(
                  color: const Color(0xff0FEEC4).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.w),
                    bottomLeft: Radius.circular(5.w),
                  ),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...() {
                          String sideText = '';
                          final discountValue = coupon?.discountValue ?? '0';
                          final intValue =
                              double.tryParse(discountValue)?.toInt() ?? 0;
                          final dtype =
                              coupon?.discountType?.toLowerCase() ?? '';

                          if (coupon?.discountType?.toLowerCase() ==
                              'percentage') {
                            sideText = 'upto $intValue% off';
                          } else if (coupon?.discountType?.toLowerCase() ==
                              'fixed') {
                            sideText = 'Flat $intValue/- off';
                          } else {
                            sideText = '$intValue off';
                          }

                          final parts = sideText.split(' ');
                          if (parts[0].toLowerCase() == 'flat' &&
                              parts.length >= 3) {
                            return [
                              Text(parts[0],
                                  style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              SizedBox(width: 1.8.w),
                              Text(parts[1],
                                  style: GoogleFonts.poppins(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                              SizedBox(width: 0.8.w),
                              Text(parts[2],
                                  style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                            ];
                          } else if (parts.length >= 2) {
                            return [
                              Text(parts[0],
                                  style: GoogleFonts.poppins(
                                      fontSize: FontSize.s14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                              SizedBox(width: 0.8.w),
                              Text(parts.sublist(1).join(' '),
                                  style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                            ];
                          } else {
                            return [
                              Text(sideText,
                                  style: GoogleFonts.poppins(
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                            ];
                          }
                        }(),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main content ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(3.w, 1.8.h, 2.5.w, 1.8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Code + Apply button row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon?.code ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s12,
                                    letterSpacing: 5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xff343434),
                                  ),
                                ),
                                SizedBox(height: 0.2.h),
                                Text(
                                  coupon?.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff212199),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Apply button
                          GestureDetector(
                            onTap: ((coupon?.isActive ?? false) &&
                                    !(coupon?.isExpired ?? true))
                                ? onApply
                                : null,
                            child: Text(
                              isApplied ? "Applied" : "Apply",
                              style: GoogleFonts.roboto(
                                fontSize: FontSize.s12,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500,
                                color: isApplied
                                    ? CommonColors.softGreen
                                    : ((coupon?.isActive ?? false) &&
                                            !(coupon?.isExpired ?? true))
                                        ? const Color(0xff4A97FF)
                                        : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      // Dotted divider
                      CustomPaint(
                        painter: DottedLinePainter(),
                        size: Size(double.infinity, 0.1.h),
                      ),
                      SizedBox(height: 0.5.h),

                      // ── Description with Read More / Show Less ────────────
                      Builder(
                        builder: (context) {
                          final description = coupon?.description ?? '';
                          final textStyle = GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withValues(alpha: 0.7),
                            height: 1.5,
                          );

                          // Length-threshold: show Read More whenever description
                          // is longer than 60 characters — no TextPainter needed.
                          final shouldShowReadMore =
                              description.trim().length > 60;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                maxLines: isExpanded ? null : 2,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: textStyle,
                              ),
                              // Read More / Show Less — shown whenever text
                              // exceeds the 60-character threshold
                              if (shouldShowReadMore)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => isExpanded = !isExpanded),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0.3.h),
                                    child: Text(
                                      isExpanded ? 'Show Less' : 'Read More',
                                      style: GoogleFonts.poppins(
                                        fontSize: FontSize.s9,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff4A97FF),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 0.4.h),

                      // ── T&C — always visible, never hidden ───────────────
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(5.w)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.6,
                            maxChildSize: 0.9,
                            minChildSize: 0.3,
                            builder: (context, scrollController) =>
                                SingleChildScrollView(
                              controller: scrollController,
                              child: _buildTermsSheet(context),
                            ),
                          ),
                        ),
                        child: Text(
                          "T&C",
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff4A97FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSheet(BuildContext context) {
    String? formattedExpiry() {
      final raw = coupon?.validUntil;
      if (raw == null || raw.isEmpty) return null;
      return ISTDateUtils.toIST(raw) != null
          ? ISTDateUtils.formatCustom(raw, 'd MMM yyyy')
          : null;
    }

    final expiryLabel = formattedExpiry();

    final List<String> fallbackTerms = [
      'Applicable on selected treks only.',
      'Coupon code is valid for a single use per customer.',
      'Additional terms & conditions may apply.',
      if (expiryLabel != null) 'Offer expires on $expiryLabel.',
      'Book now and start your adventure with Aorbo Treks!',
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 6.w, 6.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon?.code ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child:
                      Icon(Icons.close, size: 4.w, color: Colors.black54),
                ),
              ),
            ],
          ),
          if (coupon?.title != null && coupon!.title!.isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Text(
              coupon!.title!,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212199),
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Text(
            "Terms & Conditions",
            style: GoogleFonts.poppins(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          ...((coupon?.termsAndConditions != null &&
                  coupon!.termsAndConditions!.isNotEmpty)
              ? coupon!.termsAndConditions!
              : fallbackTerms)
              .map(
                (term) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: GoogleFonts.poppins(
                              fontSize: FontSize.s11,
                              color: Colors.grey[600])),
                      Expanded(
                        child: Text(term,
                            style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: Colors.grey[600],
                                height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
          if (coupon?.howToApply != null &&
              coupon!.howToApply!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              "How To Apply",
              style: GoogleFonts.poppins(
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              coupon!.howToApply!,
              style: GoogleFonts.poppins(
                  fontSize: FontSize.s10,
                  color: Colors.grey[600],
                  height: 1.4),
            ),
          ],
          SizedBox(height: 2.h),
          Text(
            coupon?.footerNote?.isNotEmpty == true
                ? coupon!.footerNote!
                : 'Book now and start your adventure with Aorbo Treks!',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212199),
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

// Dotted Line Painter
class DottedLinePainter extends CustomPainter {
  final bool isHorizontal;

  DottedLinePainter({this.isHorizontal = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffD9D9D9)
      ..strokeWidth = 0.25.w
      ..strokeCap = StrokeCap.round;

    if (isHorizontal) {
      double dashWidth = 2.w;
      double dashSpace = 1.w;
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, 0),
          Offset(startX + dashWidth, 0),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    } else {
      double dashHeight = 2.w;
      double dashSpace = 1.w;
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(0, startY),
          Offset(0, startY + dashHeight),
          paint,
        );
        startY += dashHeight + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

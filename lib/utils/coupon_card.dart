import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'common_colors.dart';
import 'screen_constants.dart';
import '../models/coupon_code/coupon_code_modal.dart';

class CouponCard extends StatelessWidget {
  final CouponCardData coupon;
  final VoidCallback onApply;
  final bool isApplied;

  const CouponCard({
    Key? key,
    required this.coupon,
    required this.onApply,
    this.isApplied = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h, left: 8.w, right: 8.w),
      child: Container(
        width: 80.w,
        height: 22.h,
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
        child: Stack(
          children: [
            // Left side mint color strip with vertical text
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
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
                          // Create side text from API data
                          String sideText = '';
                          final discountValue = coupon.discountValue ?? '0';
                          // Convert to int to remove decimal places
                          final intValue = double.tryParse(discountValue)?.toInt() ?? 0;

                          if (coupon.discountType?.toLowerCase() ==
                              'percentage') {
                            sideText = 'upto ${intValue}% off';
                          } else if (coupon.discountType?.toLowerCase() ==
                              'fixed') {
                            sideText = 'Flat ${intValue}/- off';
                          } else {
                            sideText = '${intValue} off';
                          }

                          final parts = sideText.split(' ');
                          if (parts[0].toLowerCase() == 'flat') {
                            return [
                              Text(
                                parts[0],
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 1.8.w),
                              Text(
                                parts[1],
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 0.8.w),
                              Text(
                                parts[2],
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ];
                          } else if (parts[0].toLowerCase() == 'upto') {
                            return [
                              Text(
                                parts[0],
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 0.8.w),
                              Text(
                                parts[1],
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 0.8.w),
                              Text(
                                parts[2],
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ];
                          } else {
                            return [
                              Text(
                                sideText,
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ];
                          }
                        }(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // // Dotted Line - Horizontal
            // Positioned(
            //   top: 11.h,
            //   left: 17.5.w,
            //   child: SizedBox(
            //     width: 56.25.w,
            //     child: CustomPaint(
            //       painter: DottedLinePainter(),
            //       size: Size(double.infinity, 0.1.h),
            //     ),
            //   ),
            // ),

            // Main Content
            Positioned(
              top: 1.8.h,
              left: 13.25.w,
              right: 2.25.w,
              child: Container(
                // color: Colors.red,
                height: 18.h,
                padding: EdgeInsets.only(
                  right: 2.5.w,
                  top: 0.5.w,
                  bottom: 0.5.w,
                  left: 1.5.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s12,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xff343434),
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    // Discount Text
                    Container(
                      margin: EdgeInsets.only(left: 1.w),
                      child: Text(
                        coupon.title ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,

                          fontWeight: FontWeight.w500,
                          color: const Color(0xff212199),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      width: 56.25.w,
                      child: CustomPaint(
                        painter: DottedLinePainter(),
                        size: Size(double.infinity, 0.1.h),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SizedBox(
                      width: 48.w,
                      child: RichText(
                        text: TextSpan(
                          text: "${coupon.description ?? ''} ",
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          children: [
                            if (coupon.termsAndConditions != null &&
                                coupon.termsAndConditions!.isNotEmpty)
                              TextSpan(
                                text: "T&C",
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff4A97FF),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(5.w),
                                        ),
                                      ),
                                      builder: (context) =>
                                          _buildTermsSheet(context),
                                    );
                                  },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Positioned(
              top: 1.7.h,
              right: 3.w,
              child: GestureDetector(
                onTap:
                    ((coupon.isActive ?? false) && !(coupon.isExpired ?? true))
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
                        : ((coupon.isActive ?? false) &&
                              !(coupon.isExpired ?? true))
                        ? const Color(0xff4A97FF)
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            coupon.code ?? '',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Terms & Conditions",
            style: GoogleFonts.poppins(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          ...coupon.termsAndConditions
                  ?.map(
                    (term) => Padding(
                      padding: EdgeInsets.only(bottom: 1.5.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              term,
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s10,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList() ??
              [],
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
      // Draw horizontal dotted line
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
      // Draw vertical dotted line
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

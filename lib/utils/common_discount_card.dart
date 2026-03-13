import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/models/discount_card_model.dart';
import 'package:get/get.dart';

class CommonDiscountCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String code;
  final String offerAmount;
  final String imagePath;
  final double? imageHeight;
  final String? detailedDescription;
  final String? howToApply;
  final String? termsAndConditions;
  final String? footerNote;

  const CommonDiscountCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.code,
    required this.offerAmount,
    required this.imagePath,
    this.imageHeight,
    this.detailedDescription,
    this.howToApply,
    this.termsAndConditions,
    this.footerNote,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/discount-details',
          arguments: {
            'discountCard': DiscountCardModel(
              title: title,
              subtitle: subtitle,
              color: color,
              code: code,
              offerAmount: offerAmount,
              imagePath: imagePath,
              imageHeight: imageHeight,
              detailedDescription: detailedDescription,
              howToApply: howToApply,
              termsAndConditions: termsAndConditions,
              footerNote: footerNote,
            ),
          },
          preventDuplicates: true,
        );
      },
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          // height: 180,
          decoration: BoxDecoration(color: color),
          child: Row(
            children: [
              // Vertical Offer Strip
              SizedBox(
                width: 10.w,
                // padding: const EdgeInsets.only(left: 22),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 3.8.w),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: RichText(
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.0),
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'upto '),
                            TextSpan(
                              text: offerAmount,
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(text: ' off*'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Dotted Divider
              CustomPaint(
                painter: DottedLinePainter(),
                size: Size(0.5.w, double.infinity),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(2.5.w, 1.8.h, 2.2.w, 1.2.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        subtitle,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s8,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        // margin: EdgeInsets.only(top: 29),
                        height: 8.h,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 2.6.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Text(
                                code,
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.archivoBlack(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            // const Spacer(),
                            Container(
                              alignment: FractionalOffset.centerRight,
                              // height: 75,
                              margin: EdgeInsets.only(left: 4.w),
                              width: 24.w,
                              // decoration: BoxDecoration(
                              //   color: Colors.white,
                              //   borderRadius: BorderRadius.circular(6),
                              // ),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
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
}

// Ticket-style clipper
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 5.5.w;
    double circleRadius = 4.5.w;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, (size.height / 2) - circleRadius);
    path.arcToPoint(
      Offset(size.width, (size.height / 2) + circleRadius),
      radius: Radius.circular(circleRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, (size.height / 2) + circleRadius);
    path.arcToPoint(
      Offset(0, (size.height / 2) - circleRadius),
      radius: Radius.circular(circleRadius),
      clockwise: false,
    );
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Dotted vertical divider
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CommonColors.whiteColor
      ..strokeWidth = 0.4.w
      ..strokeCap = StrokeCap.round;

    final double dashHeight = 3.w;
    final double dashSpace = 3.8.w;
    double startY = 2.2.w;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/models/discount_card_model.dart';
import 'package:get/get.dart';

class CommonDiscountCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String>? gradient;
  final String textColour;
  final String code;
  final String offerAmount;
  final String imagePath;
  final double? imageHeight;
  final String? detailedDescription;
  final String? howToApply;
  final List<String>? termsAndConditions;
  final String? footerNote;
  // validUntil used for "Offer expires on …" fallback T&C line
  final String? validUntil;

  const CommonDiscountCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.textColour,
    required this.code,
    required this.offerAmount,
    required this.imagePath,
    this.imageHeight,
    this.detailedDescription,
    this.howToApply,
    this.termsAndConditions,
    this.footerNote,
    this.validUntil,
  });

  // ── T&C bottom sheet ──────────────────────────────────────────────────────
  void _openTnc(BuildContext context) {
    // Format validUntil as "dd MMM yyyy"
    String? formattedExpiry;
    if (validUntil != null && validUntil!.isNotEmpty) {
      try {
        final dt = DateTime.parse(validUntil!);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        formattedExpiry = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        // leave null
      }
    }

    // Default T&C bullets (used when no custom T&C is set)
    final List<String> fallbackTerms = [
      'Applicable on selected treks only.',
      'Coupon code is valid for a single use per customer.',
      'Additional terms & conditions may apply.',
      if (formattedExpiry != null) 'Offer expires on $formattedExpiry.',
      'Book now and start your adventure with Aorbo Treks!',
    ];

    final List<String> displayTerms =
        (termsAndConditions != null && termsAndConditions!.isNotEmpty)
            ? termsAndConditions!
            : fallbackTerms;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Container(
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
                        code,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        child: Icon(Icons.close, size: 4.w, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                if (title.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF212199),
                    ),
                  ),
                ],
                SizedBox(height: 2.h),

                // T&C heading
                Text(
                  'Terms & Conditions',
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 1.h),

                // T&C bullets
                ...displayTerms.map(
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
                ),

                // Footer note
                SizedBox(height: 2.h),
                Text(
                  (footerNote != null && footerNote!.isNotEmpty)
                      ? footerNote!
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
          ),
        ),
      ),
    );
  }

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
              gradient: gradient,
              textColour: textColour,
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
          decoration: BoxDecoration(gradient: AppTheme.customGradient(gradient)),
          child: Row(
            children: [
              // Vertical Offer Strip
              SizedBox(
                width: 10.w,
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
                      // Title
                      Text(
                        title,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 0.6.h),

                      // Description — capped at 2 lines so T&C is always visible
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s8,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 0.4.h),

                      // T&C — always rendered separately, never inside description
                      GestureDetector(
                        // Prevent card tap from firing when user taps T&C
                        onTap: () => _openTnc(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          // Extra tap area without affecting layout
                          padding: EdgeInsets.only(top: 0.2.h, bottom: 0.2.h),
                          child: Text(
                            'T&C',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s8,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff4A97FF),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xff4A97FF),
                            ),
                          ),
                        ),
                      ),

                      // Code + image row
                      SizedBox(
                        height: 5.h,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 25.w,
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      code,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.archivoBlack(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        fontSize: 8.sp,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.copy,
                                      color: CommonColors.blackColor, size: 15),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: imagePath.isNotEmpty,
                              child: Padding(
                                padding: EdgeInsets.only(left: 2.w),
                                child: CustomNetworkImage(
                                  imageUrl: imagePath,
                                  fit: BoxFit.cover,
                                  width: 12.5.w,
                                  height: 12.5.w,
                                ),
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

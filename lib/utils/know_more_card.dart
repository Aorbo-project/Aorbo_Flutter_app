import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:sizer/sizer.dart';

class KnowMoreCard extends StatelessWidget {
  final LinearGradient customGradient;
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onKnowMoreTap;
  final double? width;
  final double? height;
  final Color? textColor;
  final double? imageHeight;
  final EdgeInsetsGeometry? padding;

  const KnowMoreCard({
    Key? key,
    required this.customGradient,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onKnowMoreTap,
    this.width,
    this.height,
    this.textColor,
    this.imageHeight,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final scaleFactor = textScaler.scale(1.0);
    return Container(
      // color: Colors.red,
      width: 300,
      margin: EdgeInsets.only(right: ScreenConstant.size20),
      child: Card(
        elevation: 3,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 165.h,
          padding: EdgeInsets.all(ScreenConstant.size16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: customGradient,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow image (fills the Stack, with offset)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: const Offset(0, 4), // vertical shadow offset
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.45),
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Main image
                  Image.asset(
                    imagePath,
                    height: 10.h,
                    width: 10.h,
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  // width: 100.w,
                  // color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AutoSizeText(
                        title,
                        textAlign: TextAlign.end,
                        // textScaler: const TextScaler.linear(1.0),
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                            fontSize: FontSize.s12,
                            // fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: textColor ?? CommonColors.blackColor),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.end,
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s8,
                          color: textColor ?? CommonColors.blackColor,
                        ),
                      ),
                      // Spacer(),
                      SizedBox(
                        height: 2.8.h,
                      ),
                      InkWell(
                        onTap: onKnowMoreTap,
                        child: Text(
                          'Know more',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  textColor ?? CommonColors.blackColor,
                              decorationThickness: 2,
                              color: textColor ?? CommonColors.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize.s9),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Example usage:
// KnowMoreCard(
//   gradientEndColor: CommonColors.appYellowColor,
//   imagePath: 'assets/images/your_image.png',
//   title: 'Your Title',
//   subtitle: 'Your Subtitle',
//   onKnowMoreTap: () {
//     // Your action here
//   },
// );

// For a custom styled card:
// KnowMoreCard(
//   gradientEndColor: CommonColors.appPurpleColor,
//   imagePath: 'assets/images/custom_image.png',
//   title: 'Custom Title',
//   subtitle: 'Custom Subtitle',
//   width: 350,
//   height: 150,
//   textColor: CommonColors.whiteColor,
//   knowMoreColor: CommonColors.appYellowColor,
//   imageHeight: 200,
//   padding: EdgeInsets.all(20),
//   customGradient: LinearGradient(
//     colors: [Colors.blue, Colors.purple],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   ),
//   onKnowMoreTap: () => print('Tapped'),
// );

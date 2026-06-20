import 'package:arobo_app/models/seasonal_forecast_data.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SeasonalForecast extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final LinearGradient? gradient;
  final Color textColour;
  final TitleStylingModel? titleStylingModel;

  const SeasonalForecast({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.gradient,
    required this.textColour,
    required this.titleStylingModel
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 23.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withValues(alpha: 0.08),
        //     spreadRadius: 0,
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 5.h,
            padding: EdgeInsets.only(
              left: 2.5.w,
              right: 2.5.w,
              top: 1.h,
              bottom: 1.h,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.customGradient(
  (titleStylingModel?.gradient ?? [])
      .map((e) => e.toString())
      .toList(),
),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [

    Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 3.w),
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textScaler: const TextScaler.linear(1.0),
          style: GoogleFonts.poppins(
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w600,
            color: AppTheme.hexToColor(
              titleStylingModel?.textColour,
            ),
          ),
        ),
      ),
    ),

    SizedBox(width: 2.w),

    CustomNetworkImage(
      imageUrl:
          titleStylingModel?.icon ?? "",
      height: 2.5.h,
      width: 2.5.h,
    ),
  ],
),
          ),

          // Body
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image Container
                Container(
                  width: 35.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomNetworkImage(
                    imageUrl: imagePath,
                    width: 35.w,
                    height: 16.h,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(width: 2.w),

                // Description & CTA Container
                Expanded(
                  child: SizedBox(
                    height: 14.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          maxLines: 3,overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w400,
                            color: textColour,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

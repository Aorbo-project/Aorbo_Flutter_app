import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TrekShorts extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const TrekShorts({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Image Background
          Image.asset(
            imagePath,
            width: 33.w,
            height: 25.h,
            fit: BoxFit.cover,
          ),

          // Gradient Overlay at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 1.6.w,
                right: 1.6.w,
                bottom: 1.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CommonColors.transparent,
                    CommonColors.blackColor.withValues(alpha: 1.2),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textScaler: const TextScaler.linear(1.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CommonColors.whiteColor,
                      fontSize: FontSize.s6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      color: CommonColors.whiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize.s7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

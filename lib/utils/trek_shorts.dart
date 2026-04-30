import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/chewie_video_player.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../models/shorts_treks_data.dart';

class TrekShorts extends StatelessWidget {
  final ShortsTreksData? shortsData;

  const TrekShorts({
    super.key,
    required this.shortsData,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Video Player with Thumbnail and Fallback Image
          ChewieVideoPlayer(
            videoUrl: shortsData?.shortVideoPath ?? "",
            thumbnailImageUrl: shortsData?.imagePath ?? "", // Shows while loading
            fallbackImageUrl: shortsData?.imagePath ?? "", // Shows on error
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
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shortsData?.description ?? "",
                    textScaler: const TextScaler.linear(1.0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.hexToColor(shortsData?.textColour),
                      fontSize: FontSize.s6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    shortsData?.title ?? "",
                    maxLines:1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      color: AppTheme.hexToColor(shortsData?.textColour),
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
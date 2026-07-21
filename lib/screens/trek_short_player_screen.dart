import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/trek_shorts.dart';
import 'package:arobo_app/widgets/youtube_shorts_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

/// The real video plays here, and only here — full screen, one video, no
/// sibling cards competing for the same swipe/drag gesture. That's what
/// makes [interactive] safe to set true: unlike the shelf, there's nothing
/// else on screen for a tap or seek gesture to be mistaken for.
class TrekShortPlayerScreen extends StatelessWidget {
  final TrekShortItem shortsData;

  const TrekShortPlayerScreen({super.key, required this.shortsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: shortsData.isVertical ? 9 / 16 : 16 / 9,
                child: YoutubeShortsPlayer(
                  videoUrl: shortsData.videoUrl,
                  thumbnailUrl: shortsData.thumbnailUrl,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                  isVertical: shortsData.isVertical,
                  interactive: true,
                  // Hides YouTube's own title/channel/CC/settings/progress
                  // chrome entirely — only our own close, mute, and
                  // play/pause controls should ever show on this screen.
                  showYoutubeControls: false,
                  showPlayPauseToggle: true,
                  autoPlayWhenVisible: false,
                  externalActive: true,
                ),
              ),
            ),
            Positioned(
              top: 1.h,
              left: 2.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 3.h,
              left: 4.w,
              right: 4.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shortsData.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.hexToColor(shortsData.textColour),
                      fontWeight: FontWeight.w600,
                      fontSize: FontSize.s11,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    shortsData.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.hexToColor(shortsData.textColour),
                      fontWeight: FontWeight.w400,
                      fontSize: FontSize.s9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

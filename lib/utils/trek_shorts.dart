import 'package:arobo_app/screens/trek_short_player_screen.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/youtube_utils.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

/// Static design-phase model — no backend/JSON wiring yet. [isVertical]
/// exists because YouTube's IFrame player can't tell a `/shorts/` upload
/// from a regular `/watch` one on its own; whoever supplies the URL has to
/// say which it is so the player frame is sized correctly (see
/// [YoutubeShortsPlayer.isVertical]).
class TrekShortItem {
  final String title;
  final String description;
  final String textColour;
  final String thumbnailUrl;
  final String videoUrl;
  final bool isVertical;

  const TrekShortItem({
    required this.title,
    required this.description,
    required this.videoUrl,
    this.textColour = '#FFFFFF',
    this.thumbnailUrl = '',
    this.isVertical = true,
  });
}

/// A shelf card: static thumbnail only, never a live video. A YouTube
/// embed is a native WebView platform view, and one swiping side by side
/// with its neighbors in a PageView fights that PageView's own drag
/// recognizer for touch priority — the exact source of the sharp corners,
/// dead swipes, and stuck-on-thumbnail bugs seen while this shelf tried to
/// autoplay inline. Tapping a card opens the real video in
/// [TrekShortPlayerScreen] instead, where there's no competing swipe
/// gesture for it to fight.
class TrekShorts extends StatelessWidget {
  final TrekShortItem shortsData;

  const TrekShorts({super.key, required this.shortsData});

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    // An admin-supplied cover image wins if present; otherwise fall back
    // to YouTube's own default thumbnail for the video — no video should
    // ever render as a plain black box just because no cover was uploaded.
    final thumbnail = shortsData.thumbnailUrl.isNotEmpty
        ? shortsData.thumbnailUrl
        : youtubeThumbnailUrl(shortsData.videoUrl);

    return ClipRRect(
      borderRadius: _radius,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.to(() => TrekShortPlayerScreen(shortsData: shortsData)),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: thumbnail != null
                    ? CustomNetworkImage(
                        imageUrl: thumbnail,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.black),
              ),

              // Play affordance — makes it obvious this is tappable, not
              // just a static picture.
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 44,
                ),
              ),

              // Gradient overlay + title/description at the bottom.
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
                        shortsData.description,
                        textScaler: const TextScaler.linear(1.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.hexToColor(shortsData.textColour),
                          fontSize: FontSize.s6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        shortsData.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0),
                        style: TextStyle(
                          color: AppTheme.hexToColor(shortsData.textColour),
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
        ),
      ),
    );
  }
}

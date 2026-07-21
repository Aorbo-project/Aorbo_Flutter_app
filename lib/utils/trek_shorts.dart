import 'package:arobo_app/screens/trek_short_player_screen.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/youtube_utils.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:arobo_app/widgets/youtube_shorts_player.dart';
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

/// A shelf card. Only the active (current) card ever mounts a live
/// player — everything else is a static thumbnail. No auto-scroll timer
/// drives this shelf, so a card only ever becomes active on a manual
/// swipe: that removes one whole source of unexpected page churn, and
/// combined with the player's own fixes (single load+play call instead of
/// a racy two-step, only one live WebView ever mounted at a time) manual
/// swiping is what's actually being tested here, not a guarantee — if the
/// same sharp-corner/dead-swipe symptoms resurface, that's the signal this
/// still isn't a stable place for a live embed. Tapping a card (active or
/// not) opens the same video in [TrekShortPlayerScreen] for the full
/// experience.
class TrekShorts extends StatelessWidget {
  final TrekShortItem shortsData;
  final bool isActive;

  const TrekShorts({
    super.key,
    required this.shortsData,
    this.isActive = false,
  });

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
              if (isActive)
                YoutubeShortsPlayer(
                  videoUrl: shortsData.videoUrl,
                  thumbnailUrl: shortsData.thumbnailUrl,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  borderRadius: _radius,
                  isVertical: shortsData.isVertical,
                  externalActive: true,
                )
              else ...[
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: thumbnail != null
                      ? ClipRect(
                          child: Transform.scale(
                            // YouTube's hqdefault fallback thumbnail is always
                            // a landscape 480x360 frame — for a vertical short
                            // it has real black pillarbox bars baked into the
                            // image itself. BoxFit.cover alone doesn't crop
                            // enough width to remove them at this card's tall
                            // aspect ratio, leaving a visible black strip next
                            // to the card's own rounded edge. Only relevant
                            // when there's no admin-supplied cover image AND
                            // the source is a vertical short — a real 16:9
                            // upload's default thumbnail has no bars to hide.
                            scale: shortsData.isVertical ? 1.9 : 1.0,
                            child: CustomNetworkImage(
                              imageUrl: thumbnail,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              fit: BoxFit.cover,
                            ),
                          ),
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
              ],

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

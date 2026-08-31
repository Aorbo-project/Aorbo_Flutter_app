import 'dart:async';

import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// In-feed native video ad card — slots into the "What's New" carousel.
///
/// Behaviour matches every feed video ad (Instagram / Swiggy):
///  • autoplays SILENTLY and loops while the card is on screen — no audio
///    ever, no player controls
///  • the app silently stops it the moment it scrolls out of view
///    (never plays an off-screen video — data, battery, and Google's
///    "disruptive ads" policy)
///  • the only tap is "Know more" / the card → the advertiser ([onCtaTap])
///  • [onImpression] fires once the card has been ≥50% visible for ≥2s
///    (IAB viewability) — the caller dedupes per session
///
/// Same footprint as [KnowMoreCard] so it reads as one more card in the row.
class SponsoredVideoCard extends StatefulWidget {
  final String videoUrl;
  final String advertiser;
  final String headline;
  final VoidCallback? onCtaTap;
  final VoidCallback? onImpression;

  /// Card width as a fraction of screen width — 88% matches KnowMoreCard.
  final double widthFraction;

  /// Trailing margin to the next card.
  final double? trailingMargin;

  const SponsoredVideoCard({
    super.key,
    required this.videoUrl,
    required this.advertiser,
    required this.headline,
    this.onCtaTap,
    this.onImpression,
    this.widthFraction = 88,
    this.trailingMargin,
  });

  @override
  State<SponsoredVideoCard> createState() => _SponsoredVideoCardState();
}

class _SponsoredVideoCardState extends State<SponsoredVideoCard> {
  VideoPlayerController? _controller;
  bool _initialised = false;
  bool _failed = false;
  bool _onScreen = false;
  bool _impressionFired = false;
  Timer? _viewabilityTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..setVolume(0); // silent — always, no toggle
    _controller!
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _initialised = true);
          _syncPlayback();
        })
        .catchError((_) {
          if (mounted) setState(() => _failed = true);
        });
  }

  @override
  void dispose() {
    _viewabilityTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  /// Play only when the card is on screen; pause otherwise.
  void _syncPlayback() {
    final c = _controller;
    if (c == null || !_initialised) return;
    if (_onScreen) {
      c.play();
    } else {
      c.pause();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible == _onScreen) return;
    _onScreen = visible;
    _syncPlayback();

    // IAB viewability: ≥50% visible for ≥2s continuous → one impression.
    if (visible && !_impressionFired) {
      _viewabilityTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _onScreen && !_impressionFired) {
          _impressionFired = true;
          widget.onImpression?.call();
        }
      });
    } else if (!visible) {
      _viewabilityTimer?.cancel();
      _viewabilityTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    const radius = 20.0;

    return VisibilityDetector(
      key: Key('sponsored-video-${widget.videoUrl}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: widget.onCtaTap,
        child: Container(
          width: widget.widthFraction.w,
          margin: EdgeInsets.only(
            right: widget.trailingMargin ?? ScreenConstant.size16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── video / placeholder
                if (_initialised && _controller != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                else
                  const _CardBackdrop(),

                if (!_initialised && !_failed)
                  const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  ),

                // ── bottom scrim for text legibility
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 12.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── "Sponsored" pill
                Positioned(
                  top: ScreenConstant.size12,
                  left: ScreenConstant.size12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SPONSORED',
                      textScaler: const TextScaler.linear(1.0),
                      style: AppType.style(
                        FontSize.s7,
                        w: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // ── advertiser + CTA
                Positioned(
                  left: ScreenConstant.size14,
                  right: ScreenConstant.size14,
                  bottom: ScreenConstant.size14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.advertiser,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0),
                        style: AppType.style(
                          FontSize.s8,
                          w: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0),
                        style: AppType.style(
                          FontSize.s12,
                          w: FontWeight.w800,
                          color: Colors.white,
                          height: 1.18,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (widget.onCtaTap != null) ...[
                        SizedBox(height: 0.5.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Know more',
                              textScaler: const TextScaler.linear(1.0),
                              style: AppType.style(
                                FontSize.s9,
                                w: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Neutral gradient shown while the video loads or if it fails.
class _CardBackdrop extends StatelessWidget {
  const _CardBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2B2A), Color(0xFF0F1B1A)],
        ),
      ),
    );
  }
}

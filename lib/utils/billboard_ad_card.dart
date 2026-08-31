import 'dart:async';

import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Full-bleed billboard ad card for the post-booking detail screens.
///
/// Edge-to-edge width, tall (~4:5 portrait). The creative image fills the
/// whole card; a bottom gradient scrim carries the "SPONSORED" tag,
/// advertiser, headline, subline and a "Know more" affordance — the same
/// visual language as [SponsoredVideoCard] so image and video ads read as
/// one format.
///
/// [onImpression] fires once the card has been ≥50% visible for ≥1s
/// (IAB viewability); the caller dedupes per session.
class BillboardAdCard extends StatefulWidget {
  final int slotId;
  final String advertiser;
  final String headline;
  final String subline;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onImpression;

  /// Card height as a fraction of screen height.
  final double heightFraction;

  /// Card width as a fraction of screen width.
  final double widthFraction;

  const BillboardAdCard({
    super.key,
    required this.slotId,
    required this.advertiser,
    required this.headline,
    required this.subline,
    required this.imageUrl,
    this.onTap,
    this.onImpression,
    this.heightFraction = 24,
    this.widthFraction = 92,
  });

  @override
  State<BillboardAdCard> createState() => _BillboardAdCardState();
}

class _BillboardAdCardState extends State<BillboardAdCard> {
  bool _impressionFired = false;
  Timer? _viewabilityTimer;

  @override
  void dispose() {
    _viewabilityTimer?.cancel();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible && !_impressionFired) {
      _viewabilityTimer ??= Timer(const Duration(seconds: 1), () {
        if (mounted && !_impressionFired) {
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

    return VisibilityDetector(
      key: Key('billboard-ad-${widget.slotId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.widthFraction.w,
          height: widget.heightFraction.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E6EC), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
              ),

              // bottom scrim for text legibility
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: (widget.heightFraction * 0.6).h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.78),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // "Sponsored" pill
              Positioned(
                top: ScreenConstant.size12,
                left: ScreenConstant.size14,
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

              // advertiser + headline + subline + CTA
              Positioned(
                left: ScreenConstant.size16,
                right: ScreenConstant.size16,
                bottom: ScreenConstant.size18,
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
                    const SizedBox(height: 3),
                    Text(
                      widget.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1.0),
                      style: AppType.style(
                        FontSize.s14,
                        w: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (widget.subline.isNotEmpty) ...[
                      SizedBox(height: 0.3.h),
                      Text(
                        widget.subline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0),
                        style: AppType.style(
                          FontSize.s9,
                          color: Colors.white.withValues(alpha: 0.82),
                          height: 1.3,
                        ),
                      ),
                    ],
                    SizedBox(height: 0.9.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.5.w,
                        vertical: 0.9.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Know more',
                            textScaler: const TextScaler.linear(1.0),
                            style: AppType.style(
                              FontSize.s9,
                              w: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF111827),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

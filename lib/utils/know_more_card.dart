import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sizer/sizer.dart';

/// Material 3 "emphasized decelerate" easing — used for content entering the
/// viewport (as opposed to "standard" easing, used for micro-interactions
/// between on-screen elements). See m3.material.io/styles/motion.
const _emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

/// What's New promo card.
///
/// Layout is fixed-footprint by design: the image sits in a constant-size
/// box (scaled to fit, never cropped) and the text column reserves its own
/// fixed height with capped line counts — so card content never shifts
/// position or size no matter how long/short the admin-entered text is.
class KnowMoreCard extends StatefulWidget {
  /// Two hex colors, e.g. ['#FFE066', '#FFC300']. Passed as raw hex (not a
  /// pre-built gradient) so the card can also derive a tinted shadow from
  /// the same palette.
  final List<String> gradientColors;
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onKnowMoreTap;
  final Color? textColor;

  /// Card width as a fraction of screen width. Defaults to 88% for the
  /// horizontal carousel (leaves the next card peeking at the edge); pass
  /// a larger value (e.g. 92) for a full vertical list.
  final double widthFraction;

  /// Trailing margin — spacing to the next card. Set to 0 when the caller
  /// (e.g. a ListView with its own separators) already handles spacing.
  final double? trailingMargin;

  const KnowMoreCard({
    super.key,
    required this.gradientColors,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onKnowMoreTap,
    this.textColor,
    this.widthFraction = 88,
    this.trailingMargin,
  });

  @override
  State<KnowMoreCard> createState() => _KnowMoreCardState();
}

class _KnowMoreCardState extends State<KnowMoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);
    final textColor = widget.textColor ?? CommonColors.blackColor;

    final colors = widget.gradientColors.isEmpty
        ? ['#0F7B6C', '#1AA090']
        : widget.gradientColors;
    final startColor = AppTheme.hexToColor(colors.first);
    final endColor = AppTheme.hexToColor(colors.last);
    final shadowColor = Color.lerp(startColor, endColor, 0.6)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: _emphasizedDecelerate,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onKnowMoreTap,
        onTapDown: (_) => _pressController.animateTo(0.97,
            duration: const Duration(milliseconds: 100)),
        onTapUp: (_) => _pressController.animateTo(1.0,
            duration: const Duration(milliseconds: 150)),
        onTapCancel: () => _pressController.animateTo(1.0,
            duration: const Duration(milliseconds: 150)),
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) => Transform.scale(
            scale: _pressController.value,
            child: child,
          ),
          child: Container(
            width: widget.widthFraction.w,
            margin: EdgeInsets.only(
              right: widget.trailingMargin ?? ScreenConstant.size16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Diagonal gradient base — flat centerLeft→centerRight
                  // reads static; a 135° diagonal is the industry-standard
                  // choice for this "feature spotlight" card category.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [startColor, endColor],
                        ),
                      ),
                    ),
                  ),
                  // Soft radial highlight behind the illustration for depth.
                  Positioned(
                    left: -10.w,
                    top: -8.h,
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(ScreenConstant.size16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Fixed-size illustration box with its own soft
                        // drop shadow so it feels lifted off the card,
                        // instead of pasted flat onto the gradient.
                        SizedBox(
                          width: 30.w,
                          height: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                bottom: 2.h,
                                child: Container(
                                  width: 18.w,
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.black.withValues(alpha: 0.14),
                                  ),
                                ),
                              ),
                              // Positioned.fill forces the image to claim
                              // the full box — a bare child inside a Stack
                              // shrink-wraps to its own intrinsic size
                              // instead of filling available space.
                              Positioned.fill(
                                child: CustomNetworkImage(
                                  imageUrl: widget.imagePath,
                                  fit: BoxFit.contain,
                                  hasTransparentBackground: true,
                                  borderRadius: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: ScreenConstant.size12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: ScreenConstant.size4),
                              Text(
                                widget.subtitle,
                                textAlign: TextAlign.start,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s8,
                                  color: textColor.withValues(alpha: 0.85),
                                  height: 1.35,
                                ),
                              ),
                              if (widget.onKnowMoreTap != null) ...[
                                SizedBox(height: ScreenConstant.size8),
                                // Visual affordance only — the whole card
                                // (outer GestureDetector) already handles
                                // the tap, so this isn't its own InkWell
                                // (avoids double-firing navigation).
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Know more',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.poppins(
                                        color: textColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: FontSize.s9,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: textColor.withValues(alpha: 0.16),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 11,
                                        color: textColor,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

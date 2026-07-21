import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Material 3 "emphasized decelerate" easing — same entrance curve as
/// KnowMoreCard, so cards across the app feel like one system.
const _emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

/// Coupon card, built to extend KnowMoreCard's established visual system
/// (utils/know_more_card.dart) rather than invent a separate "ticket" style:
/// same diagonal gradient, same 20px radius, same gradient-tinted soft
/// shadow, same Poppins scale, same press-scale + fade-in entrance. What's
/// coupon-specific is the content inside — a big discount headline instead
/// of an illustration, a condition line, a code pill, and a T&C link.
class CouponGradientCard extends StatefulWidget {
  /// Two hex colors, e.g. ['#0F7B6C', '#1AA090']. Defaults to Aorbo teal —
  /// same default as KnowMoreCard — so a coupon with no admin-set color
  /// still matches the rest of the app instead of falling back to grey.
  final List<String> gradientColors;
  final Color? textColor;

  /// Short category tag, e.g. "SEASONAL", "NEW TREKKER", "GROUPS OF 4+" —
  /// shown above the headline so the offer's nature reads before its size.
  final String? badgeLabel;

  /// Pre-composed headline, e.g. "FLAT ₹200 OFF" or "20% OFF" — built by
  /// the caller from discount_type/discount_value, not by this widget,
  /// since that mapping differs per coupon type.
  final String headline;

  /// e.g. "Upto ₹300 · On orders above ₹4,500" — the two universal
  /// conditions (cap, min order) collapsed into one line.
  final String conditionText;

  final String code;
  final VoidCallback? onCopyCode;
  final VoidCallback? onTapTnC;
  final VoidCallback? onTap;

  final double widthFraction;
  final double? trailingMargin;

  const CouponGradientCard({
    super.key,
    required this.gradientColors,
    required this.headline,
    required this.conditionText,
    required this.code,
    this.badgeLabel,
    this.textColor,
    this.onCopyCode,
    this.onTapTnC,
    this.onTap,
    this.widthFraction = 88,
    this.trailingMargin,
  });

  @override
  State<CouponGradientCard> createState() => _CouponGradientCardState();
}

class _CouponGradientCardState extends State<CouponGradientCard>
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
    final textColor = widget.textColor ?? Colors.white;

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
        onTap: widget.onTap,
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
                  // Soft radial highlight — same depth cue as KnowMoreCard,
                  // placed top-right here since the code pill/T&C sit
                  // bottom-left and shouldn't compete with it.
                  Positioned(
                    right: -10.w,
                    top: -10.h,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenConstant.size18,
                      vertical: ScreenConstant.size16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top block: what kind of offer this is, then how big
                        // it is. Tag reads first so the headline number has
                        // context before you even register its size.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.badgeLabel != null &&
                                widget.badgeLabel!.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.2.w,
                                  vertical: 0.45.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  widget.badgeLabel!.toUpperCase(),
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s7,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.1.h),
                            ],
                            // The discount amount is the single largest,
                            // boldest thing on the card — never a rotated
                            // side-strip.
                            Text(
                              widget.headline,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s20,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                height: 1.1,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 0.7.h),
                            Text(
                              widget.conditionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                color: textColor.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),

                        // Footer: code on the left, T&C on the right — the
                        // extra height means these no longer have to sit
                        // pressed together on one edge.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: widget.onCopyCode,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.9.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.code,
                                      textScaler: const TextScaler.linear(1.0),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: startColor,
                                        fontSize: FontSize.s9,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    SizedBox(width: 1.8.w),
                                    Icon(Icons.copy_rounded,
                                        size: 14, color: startColor),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onTapTnC,
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                'T&C*',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w600,
                                  color: textColor.withValues(alpha: 0.9),
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      textColor.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
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

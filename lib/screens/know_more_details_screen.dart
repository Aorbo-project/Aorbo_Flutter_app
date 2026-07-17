import 'package:arobo_app/models/know_more_data.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';

const _emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

class KnowMoreDetailsScreen extends StatelessWidget {
  final KnowMoreData? knowMoreData;

  const KnowMoreDetailsScreen({
    super.key,
    required this.knowMoreData,
  });

  @override
  Widget build(BuildContext context) {
    final colors = (knowMoreData?.gradient?.isNotEmpty ?? false)
        ? knowMoreData!.gradient!
        : ['#0F7B6C', '#1AA090'];
    final startColor = AppTheme.hexToColor(colors.first);
    final endColor = AppTheme.hexToColor(colors.last);
    final textColor = AppTheme.hexToColor(knowMoreData?.textColour ?? '#FFFFFF');
    final bulletPoints = knowMoreData?.bulletPoints ?? [];

    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ────────────────────────────────────────
            _AnimatedEntrance(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [startColor, endColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(startColor, endColor, 0.6)!
                            .withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Soft decorative glow — same device used on the card,
                      // carried through here for visual continuity.
                      Positioned(
                        right: -12.w,
                        top: -6.h,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -8.w,
                        bottom: -10.h,
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenConstant.size16,
                              vertical: ScreenConstant.size8,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => Get.back(),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                  child: Icon(Icons.close, color: textColor, size: 20),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenConstant.size20,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Illustration holder — lifted off the
                                // gradient with its own soft shadow, instead
                                // of sitting flat against the banner.
                                SizedBox(
                                  width: 34.w,
                                  height: 34.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 28.w,
                                        height: 28.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.18,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: CustomNetworkImage(
                                            imageUrl: knowMoreData?.imagePath ?? '',
                                            fit: BoxFit.contain,
                                            hasTransparentBackground: true,
                                            borderRadius: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: ScreenConstant.size16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Introducing to',
                                        textScaler: const TextScaler.linear(1.0),
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s10,
                                          color: textColor.withValues(alpha: 0.85),
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        knowMoreData?.title ?? '',
                                        textScaler: const TextScaler.linear(1.0),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s16,
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.8.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.5.h),

            // ── Body ──────────────────────────────────────────────────
            if (knowMoreData?.detailedTitle != null)
              _AnimatedEntrance(
                delay: 80,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenConstant.size16),
                  child: _SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          knowMoreData?.detailedTitle ?? '',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s15,
                            fontWeight: FontWeight.w700,
                            color: CommonColors.blackColor,
                          ),
                        ),
                        if (knowMoreData?.detailedDescription != null) ...[
                          SizedBox(height: 1.2.h),
                          Text(
                            knowMoreData?.detailedDescription ?? '',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              height: 1.6,
                              color: CommonColors.blackColor.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            if (bulletPoints.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenConstant.size16),
                child: _SoftCard(
                  padding: EdgeInsets.symmetric(vertical: ScreenConstant.size12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenConstant.size16,
                        ),
                        child: Text(
                          'Why it matters',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w700,
                            color: CommonColors.blackColor.withValues(alpha: 0.5),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      ...List.generate(bulletPoints.length, (index) {
                        return _AnimatedEntrance(
                          delay: 120 + (index * 60),
                          child: Column(
                            children: [
                              _StepRow(
                                number: index + 1,
                                text: bulletPoints[index].text ?? '',
                                startColor: startColor,
                                endColor: endColor,
                              ),
                              if (index != bulletPoints.length - 1)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenConstant.size16,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: CommonColors.blackColor.withValues(
                                      alpha: 0.06,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 3.h),

            // ── Call to action ────────────────────────────────────────
            if (knowMoreData?.callToAction?.isNotEmpty ?? false)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenConstant.size16),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: startColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: startColor,
                        foregroundColor: textColor,
                        padding: EdgeInsets.symmetric(vertical: ScreenConstant.size14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            knowMoreData?.callToAction ?? '',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

/// White, softly-shadowed grouping container — separates page sections from
/// the light-gray scaffold background instead of everything sitting flat
/// on one plane.
class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _SoftCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(ScreenConstant.size16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String text;
  final Color startColor;
  final Color endColor;

  const _StepRow({
    required this.number,
    required this.text,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.size16,
        vertical: ScreenConstant.size10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 9.w,
            height: 9.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  startColor.withValues(alpha: 0.18),
                  endColor.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: Text(
              '$number',
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w800,
                color: startColor,
              ),
            ),
          ),
          SizedBox(width: ScreenConstant.size12),
          Expanded(
            child: Text(
              text,
              textScaler: const TextScaler.linear(1.0),
              style: GoogleFonts.poppins(
                fontSize: FontSize.s10,
                height: 1.4,
                color: CommonColors.blackColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared fade + slide-up entrance, matching the What's New card's motion
/// language (M3 "emphasized decelerate" easing for content entering view).
class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntrance({required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delay),
      curve: _emphasizedDecelerate,
      builder: (context, value, c) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

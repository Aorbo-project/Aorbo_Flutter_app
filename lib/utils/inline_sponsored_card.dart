import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A full-width in-content ad card for the vertical detail screens
/// (Booking Details, Cancellation Status). Sits between the existing
/// section cards and reads as "one more card in the stack".
///
/// External brand ads only — direct-sold or AdMob-filled. No Aorbo
/// cross-sell here (gear/insurance is the vendor's, not Aorbo's).
///
/// DESIGN PASS: content is hard-coded by the caller. When wired it takes
/// the same fields as the other sponsored slots (advertiser / headline /
/// image or video / cta).
class InlineSponsoredCard extends StatelessWidget {
  final String advertiser;
  final String headline;
  final String subline;
  final String ctaLabel;
  final String imageUrl;
  final VoidCallback? onTap;

  const InlineSponsoredCard({
    super.key,
    required this.advertiser,
    required this.headline,
    required this.subline,
    required this.ctaLabel,
    required this.imageUrl,
    this.onTap,
  });

  static const _accent = Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDF2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: 13.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 30.w,
                height: double.infinity,
                child: CustomNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(3.5.w, 1.4.h, 3.5.w, 1.4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SPONSORED',
                              textScaler: const TextScaler.linear(1),
                              style: AppType.style(
                                FontSize.s7,
                                w: FontWeight.w700,
                                color: _accent,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              advertiser,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: const TextScaler.linear(1),
                              style: AppType.style(
                                FontSize.s7,
                                w: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.7.h),
                      Text(
                        headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1),
                        style: AppType.style(
                          FontSize.s11,
                          w: FontWeight.w800,
                          color: const Color(0xFF111827),
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        subline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1),
                        style: AppType.style(
                          FontSize.s8,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ctaLabel,
                            textScaler: const TextScaler.linear(1),
                            style: AppType.style(
                              FontSize.s9,
                              w: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 13, color: _accent),
                        ],
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

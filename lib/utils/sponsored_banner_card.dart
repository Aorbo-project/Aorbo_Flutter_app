import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Compact in-list brand ad banner. Sits at the BOTTOM of the search
/// results, after every real trek — never between route matches.
///
/// DUMMY: content is hard-coded for the design pass. When wired up it
/// takes the same fields as the dashboard sponsored slots
/// (advertiser / headline / imageUrl or videoUrl / ctaUrl).
class SponsoredBannerCard extends StatelessWidget {
  final String advertiser;
  final String headline;
  final VoidCallback? onTap;

  const SponsoredBannerCard({
    super.key,
    required this.advertiser,
    required this.headline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 13.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B2B2A), Color(0xFF14201F)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'SPONSORED',
                        textScaler: const TextScaler.linear(1),
                        style: AppType.style(
                          FontSize.s7,
                          w: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
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
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      '$advertiser · Know more',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1),
                      style: AppType.style(
                        FontSize.s8,
                        w: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

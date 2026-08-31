import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/sponsored_slot_data.dart';
import 'package:arobo_app/utils/inline_sponsored_card.dart';
import 'package:arobo_app/utils/native_feed_ad_card.dart';
import 'package:arobo_app/utils/sponsored_video_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// One in-content ad position on a post-booking detail screen
/// (`booking_details` / `cancellation_status`), at [index].
///
/// Waterfall per position:
///   1. a direct-sold slot at data index [index]  → image or video card
///   2. else, if the AdMob toggle is on            → AdMob native card
///   3. else                                       → nothing (0 height)
///
/// The screen inserts a few of these at fixed points; the controller
/// fetches the slot list once via `fetchDetailScreenAds(screen)`.
///
/// When there is nothing to show, this collapses to a true zero-size box —
/// including the leading gap — so an unsold position leaves no dead space.
class DetailScreenAdSlot extends StatelessWidget {
  final String screen;
  final int index;

  /// Horizontal inset. Default matches the other section cards; pass 0 when
  /// the parent already applies side padding.
  final double? horizontalPadding;

  const DetailScreenAdSlot({
    super.key,
    required this.screen,
    required this.index,
    this.horizontalPadding,
  });

  DashboardController get _c => Get.find<DashboardController>();

  Future<void> _openCta(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ads = _c.detailScreenAds[screen] ?? const <SponsoredSlot>[];
      final Widget? card = _resolveCard(ads);
      if (card == null) return const SizedBox.shrink();

      final double hPad = horizontalPadding ?? 4.w;
      return Padding(
        padding: EdgeInsets.only(
          top: 1.5.h,
          bottom: 1.5.h,
          left: hPad,
          right: hPad,
        ),
        child: card,
      );
    });
  }

  /// The card for this position, or null when there is nothing to show.
  Widget? _resolveCard(List<SponsoredSlot> ads) {
    if (index < ads.length) {
      final slot = ads[index];
      _c.logSponsoredImpression(slot.id);

      if (slot.isBrandVideo) {
        return SizedBox(
          width: 92.w,
          height: 22.h,
          child: SponsoredVideoCard(
            key: ValueKey('ds-ad-${slot.id}'),
            slotId: slot.id,
            videoUrl: slot.videoUrl ?? '',
            advertiser: slot.advertiser,
            headline: slot.headline ?? '',
            widthFraction: 92,
            trailingMargin: 0,
            onImpression: () => _c.logSponsoredImpression(slot.id),
            onCtaTap: () {
              _c.logSponsoredClick(slot.id);
              _openCta(slot.ctaUrl);
            },
          ),
        );
      }

      // brand_banner
      return InlineSponsoredCard(
        advertiser: slot.advertiser,
        headline: slot.headline ?? '',
        subline: slot.subline ?? '',
        ctaLabel: 'Know more',
        imageUrl: slot.imageUrl ?? '',
        onTap: () {
          _c.logSponsoredClick(slot.id);
          _openCta(slot.ctaUrl);
        },
      );
    }

    // Waterfall → AdMob fill (only when the toggle is on).
    if (_c.admobFallbackEnabled.value) {
      return SizedBox(
        width: 92.w,
        height: 20.h,
        child: const NativeFeedAdCard(
          widthFraction: 92,
          trailingMargin: 0,
        ),
      );
    }

    return null;
  }
}

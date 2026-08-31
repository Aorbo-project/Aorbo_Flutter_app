import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/models/sponsored_slot_data.dart';
import 'package:arobo_app/utils/billboard_ad_card.dart';
import 'package:arobo_app/utils/native_feed_ad_card.dart';
import 'package:arobo_app/utils/sponsored_video_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// One in-content ad position on a post-booking detail screen
/// (`booking_details` / `cancellation_status`), at [index].
///
/// Compact landscape billboard — an inset card (4.w side margin, rounded,
/// visible border) whose creative image or video fills the frame, with the
/// "SPONSORED" tag, headline, subline and "Know more" overlaid on a bottom
/// gradient — the same visual language as the What's New video card.
///
/// Waterfall per position:
///   1. a direct-sold slot at data index [index]  → image or video billboard
///   2. else, if the AdMob toggle is on            → AdMob native card
///   3. else                                       → nothing (0 height)
///
/// When there is nothing to show, this collapses to a true zero-size box —
/// including the leading gap — so an unsold position leaves no dead space.
class DetailScreenAdSlot extends StatelessWidget {
  final String screen;
  final int index;

  const DetailScreenAdSlot({
    super.key,
    required this.screen,
    required this.index,
  });

  DashboardController get _c => Get.find<DashboardController>();

  /// Card footprint.
  static const double _heightFraction = 24;
  static const double _widthFraction = 92;
  static const _border = Border.fromBorderSide(
    BorderSide(color: Color(0xFFE1E6EC), width: 1),
  );

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

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
          width: _widthFraction.w,
          height: _heightFraction.h,
          child: SponsoredVideoCard(
            key: ValueKey('ds-ad-${slot.id}'),
            slotId: slot.id,
            videoUrl: slot.videoUrl ?? '',
            advertiser: slot.advertiser,
            headline: slot.headline ?? '',
            widthFraction: _widthFraction,
            trailingMargin: 0,
            borderRadius: 18,
            border: _border,
            onImpression: () => _c.logSponsoredImpression(slot.id),
            onCtaTap: () {
              _c.logSponsoredClick(slot.id);
              _openCta(slot.ctaUrl);
            },
          ),
        );
      }

      // brand_banner
      return BillboardAdCard(
        slotId: slot.id,
        advertiser: slot.advertiser,
        headline: slot.headline ?? '',
        subline: slot.subline ?? '',
        imageUrl: slot.imageUrl ?? '',
        heightFraction: _heightFraction,
        widthFraction: _widthFraction,
        onImpression: () => _c.logSponsoredImpression(slot.id),
        onTap: () {
          _c.logSponsoredClick(slot.id);
          _openCta(slot.ctaUrl);
        },
      );
    }

    // Waterfall → AdMob fill (only when the toggle is on).
    if (_c.admobFallbackEnabled.value) {
      return SizedBox(
        width: _widthFraction.w,
        height: 30.h,
        child: const NativeFeedAdCard(
          widthFraction: _widthFraction,
          trailingMargin: 0,
        ),
      );
    }

    return null;
  }
}

import 'package:arobo_app/config/ad_config.dart';
import 'package:arobo_app/services/ad_consent_service.dart';
import 'package:arobo_app/theme/app_tokens.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A real AdMob native ad rendered in the same footprint as the in-feed
/// sponsored cards, via the native "feedCard" factory (see
/// android/.../NativeAdFactoryImpl.kt). Google fills the content, owns the
/// click, and never exposes a URL — a tap on the card redirects itself.
///
/// Waterfall bottom: if the ad doesn't fill (no demand / consent denied)
/// and [allowHouseAd] is true, an Aorbo house card is shown so a carousel
/// slot is never blank. Set [allowHouseAd] false for surfaces where an
/// empty slot is fine (a scrollable Row that can just be shorter).
class NativeFeedAdCard extends StatefulWidget {
  /// Card width as a fraction of screen width (matches KnowMoreCard = 88).
  final double widthFraction;
  final double? trailingMargin;

  /// Fires once when a filled ad has been ≥50% visible for ≥1s.
  final VoidCallback? onImpression;

  /// Show the Aorbo house card instead of nothing when the ad doesn't fill.
  final bool allowHouseAd;

  const NativeFeedAdCard({
    super.key,
    this.widthFraction = 88,
    this.trailingMargin,
    this.onImpression,
    this.allowHouseAd = false,
  });

  @override
  State<NativeFeedAdCard> createState() => _NativeFeedAdCardState();
}

class _NativeFeedAdCardState extends State<NativeFeedAdCard> {
  NativeAd? _ad;
  bool _loaded = false;
  bool _failed = false;
  bool _impressionFired = false;
  int _consentWaits = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (!AdConsentService.instance.canRequestAds) {
      // Consent may still be resolving at first frame — poll a few times
      // before giving up.
      if (_consentWaits < 5) {
        _consentWaits++;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && !_loaded) _load();
        });
        return;
      }
      if (mounted) setState(() => _failed = true);
      return;
    }
    _ad = NativeAd(
      adUnitId: AdConfig.nativeFeedUnitId,
      factoryId: 'feedCard',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _failed = true);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  void _onVisibility(VisibilityInfo info) {
    if (_impressionFired || !_loaded) return;
    if (info.visibleFraction > 0.5) {
      _impressionFired = true;
      widget.onImpression?.call();
    }
  }

  BoxDecoration get _shell => BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final noAd = _failed || !_loaded || _ad == null;

    if (noAd) {
      if (!widget.allowHouseAd) return const SizedBox.shrink();
      // Only fall to a house card once we're SURE there's no ad (failed) —
      // while still loading, take no space.
      if (!_failed) return const SizedBox.shrink();
      return Container(
        width: widget.widthFraction.w,
        margin: EdgeInsets.only(right: widget.trailingMargin ?? 4.w),
        clipBehavior: Clip.antiAlias,
        decoration: _shell,
        child: const _HouseAdCard(),
      );
    }

    return VisibilityDetector(
      key: Key('native-ad-${identityHashCode(_ad)}'),
      onVisibilityChanged: _onVisibility,
      child: Container(
        width: widget.widthFraction.w,
        margin: EdgeInsets.only(right: widget.trailingMargin ?? 4.w),
        clipBehavior: Clip.antiAlias,
        decoration: _shell,
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}

/// Aorbo's own card, shown when no paid or network ad filled the slot.
class _HouseAdCard extends StatelessWidget {
  const _HouseAdCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/popular-treks'),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.forestDeep, AppColors.forest],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AORBO TREKS',
                textScaler: const TextScaler.linear(1),
                style: AppType.style(
                  FontSize.s8,
                  w: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.4,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Every trail,\none app',
                    textScaler: const TextScaler.linear(1),
                    style: AppType.style(
                      FontSize.s15,
                      w: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore treks',
                        textScaler: const TextScaler.linear(1),
                        style: AppType.style(
                          FontSize.s10,
                          w: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:arobo_app/config/ad_config.dart';
import 'package:arobo_app/services/ad_consent_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A real AdMob native ad rendered in the same footprint as the in-feed
/// sponsored cards, via the native "feedCard" factory (see
/// android/.../NativeAdFactoryImpl.kt). Google fills the content, owns the
/// click, and never exposes a URL — a tap on the card redirects itself.
///
/// Fails silently: if consent isn't granted or the ad doesn't fill, the
/// widget renders nothing (height 0) so the row just shows organic cards.
class NativeFeedAdCard extends StatefulWidget {
  /// Card width as a fraction of screen width (matches KnowMoreCard = 88).
  final double widthFraction;
  final double? trailingMargin;

  /// Fires once when a filled ad has been ≥50% visible for ≥1s.
  final VoidCallback? onImpression;

  const NativeFeedAdCard({
    super.key,
    this.widthFraction = 88,
    this.trailingMargin,
    this.onImpression,
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

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    if (!_loaded || _ad == null) {
      // Reserve nothing until it fills — keeps the row clean on no-fill.
      return const SizedBox.shrink();
    }

    return VisibilityDetector(
      key: Key('native-ad-${identityHashCode(_ad)}'),
      onVisibilityChanged: _onVisibility,
      child: Container(
        width: widget.widthFraction.w,
        margin: EdgeInsets.only(right: widget.trailingMargin ?? 4.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}

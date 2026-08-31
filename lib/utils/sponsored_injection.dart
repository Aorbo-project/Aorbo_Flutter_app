import 'package:arobo_app/models/sponsored_slot_data.dart';

/// Injects sponsored creatives into an organic card list, honouring the
/// feed-ad density rules every market app follows:
///
///  • never the very first card, never the very last
///  • at least [minGap] slots between two consecutive ads (so real cards
///    always separate them)
///  • the 2nd ad (and beyond) is AUTO-GATED — it only appears once the
///    organic list is long enough ([nextAdMinOrganic]) that the spacing
///    above actually fits. Short carousels just show one ad.
///
/// Returns a fresh list whose items are either the original organic type
/// `T` or a [SponsoredSlot]. Callers branch on `item is SponsoredSlot`.
List<Object> injectSponsoredSlots({
  required List<Object> organic,
  required List<SponsoredSlot> slots,
  int firstAdMinOrganic = 2,
  int nextAdMinOrganic = 6,
  int minGap = 3,
  int maxAds = 2,
  bool allowLast = false,
}) {
  final result = List<Object>.from(organic);
  if (slots.isEmpty || organic.length < firstAdMinOrganic) return result;

  final ordered = [...slots]
    ..sort((a, b) => a.position.compareTo(b.position));

  final placedAt = <int>[];
  for (var i = 0; i < ordered.length && i < maxAds; i++) {
    final needed = i == 0 ? firstAdMinOrganic : nextAdMinOrganic;
    if (organic.length < needed) break;

    final low = placedAt.isEmpty ? 1 : placedAt.last + minGap;
    final high = allowLast ? result.length : result.length - 1;
    if (low > high) break;

    final at = ordered[i].position.clamp(low, high);
    result.insert(at, ordered[i]);
    placedAt.add(at);
  }
  return result;
}

/// Marker item: this position should try to fill with an AdMob native ad.
/// The widget renders nothing if the ad doesn't fill, so a marker is safe
/// to insert unconditionally.
class AdmobFeedSlot {
  const AdmobFeedSlot();
}

/// Waterfall: house / direct-sold inventory wins; AdMob only mops up what
/// wasn't sold. If [feed] already carries a [SponsoredSlot] (a paid slot
/// filled this row), it's returned untouched. Otherwise — and only when
/// the row has enough organic cards — one [AdmobFeedSlot] marker is
/// dropped in at [position].
List<Object> withAdmobFallback(
  List<Object> feed, {
  required int organicCount,
  required bool enabled,
  int minOrganic = 2,
  int position = 2,
}) {
  if (!enabled) return feed;
  final hasDirectSold = feed.any((e) => e is SponsoredSlot);
  if (hasDirectSold || organicCount < minOrganic) return feed;
  final out = List<Object>.from(feed);
  out.insert(position.clamp(1, out.length), const AdmobFeedSlot());
  return out;
}

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

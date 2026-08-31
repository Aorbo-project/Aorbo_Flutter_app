/// GET /api/v1/discovery/sponsored-slots
///
/// Up to two creatives per dashboard row, chosen server-side by weighted
/// rotation and ordered by `position`:
///   { "data": { "whats_new": [ {...} ], "top_treks": [ {...} ],
///               "seasonal_forecast": [ {...} ] } }
class SponsoredSlotsResponse {
  final bool success;
  final List<SponsoredSlot> whatsNew;
  final List<SponsoredSlot> topTreks;
  final List<SponsoredSlot> seasonalForecast;

  /// Server switch: may an AdMob native ad fill an unsold in-feed slot?
  final bool admobFallback;

  SponsoredSlotsResponse({
    required this.success,
    this.whatsNew = const [],
    this.topTreks = const [],
    this.seasonalForecast = const [],
    this.admobFallback = false,
  });

  factory SponsoredSlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};

    List<SponsoredSlot> parseRow(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(SponsoredSlot.fromJson)
            .toList();
      }
      // tolerate the earlier single-object shape
      if (raw is Map<String, dynamic>) return [SponsoredSlot.fromJson(raw)];
      return const [];
    }

    return SponsoredSlotsResponse(
      success: json['success'] == true,
      whatsNew: parseRow(data['whats_new']),
      topTreks: parseRow(data['top_treks']),
      seasonalForecast: parseRow(data['seasonal_forecast']),
      admobFallback: json['admobFallback'] == true,
    );
  }
}

/// GET `/api/v1/discovery/search-sponsored?destination_id=`
///
///   `data.listing` = `{ slotId, advertiser, trek }` where `trek` matches
///   one entry of `/treks` `data[]`; `data.banner` = a brand-ad slot.
///
/// `listing.trek` is a raw JSON map — the caller parses it with
/// `TrekData.fromJson` so the sponsored trek renders in the exact same
/// card as an organic result. `banner` is a brand ad.
class SearchSponsoredResponse {
  final bool success;
  final SponsoredListing? listing;
  final SponsoredSlot? banner;
  final bool admobFallback;

  SearchSponsoredResponse({
    required this.success,
    this.listing,
    this.banner,
    this.admobFallback = false,
  });

  factory SearchSponsoredResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return SearchSponsoredResponse(
      success: json['success'] == true,
      listing: data['listing'] is Map<String, dynamic>
          ? SponsoredListing.fromJson(data['listing'] as Map<String, dynamic>)
          : null,
      banner: data['banner'] is Map<String, dynamic>
          ? SponsoredSlot.fromJson(data['banner'] as Map<String, dynamic>)
          : null,
      admobFallback: json['admobFallback'] == true,
    );
  }
}

/// A paid "Sponsored" trek in the search results. `trekJson` is the raw
/// `/treks`-shaped map — parse with `TrekData.fromJson`.
class SponsoredListing {
  final int slotId;
  final String advertiser;
  final Map<String, dynamic> trekJson;

  SponsoredListing({
    required this.slotId,
    required this.advertiser,
    required this.trekJson,
  });

  int? get trekId => (trekJson['id'] as num?)?.toInt();

  factory SponsoredListing.fromJson(Map<String, dynamic> json) {
    return SponsoredListing(
      slotId: (json['slotId'] as num?)?.toInt() ?? 0,
      advertiser: json['advertiser']?.toString() ?? '',
      trekJson: (json['trek'] as Map<String, dynamic>?) ?? const {},
    );
  }
}

class SponsoredSlot {
  final int id;
  final String row; // 'whats_new' | 'top_treks' | 'seasonal_forecast'
  final String slotType; // 'brand_video' | 'sponsored_trek'
  final int position;
  final String advertiser;

  // brand_video
  final String? headline;
  final String? videoUrl;
  final String? posterUrl;
  final String? ctaUrl;

  // sponsored_trek (dashboard "Top Treks")
  final int? trekId;
  final String? title;
  final String? kicker;
  final String? meta;
  final String? imagePath;
  final String? detailUrl;

  SponsoredSlot({
    required this.id,
    required this.row,
    required this.slotType,
    required this.position,
    required this.advertiser,
    this.headline,
    this.videoUrl,
    this.posterUrl,
    this.ctaUrl,
    this.trekId,
    this.title,
    this.kicker,
    this.meta,
    this.imagePath,
    this.detailUrl,
  });

  bool get isBrandVideo => slotType == 'brand_video';
  bool get isSponsoredTrek => slotType == 'sponsored_trek';

  factory SponsoredSlot.fromJson(Map<String, dynamic> json) {
    return SponsoredSlot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      row: json['row']?.toString() ?? '',
      slotType: json['slotType']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt() ?? 2,
      advertiser: json['advertiser']?.toString() ?? '',
      headline: json['headline']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      posterUrl: json['posterUrl']?.toString(),
      ctaUrl: json['ctaUrl']?.toString(),
      trekId: (json['trekId'] as num?)?.toInt(),
      title: json['title']?.toString(),
      kicker: json['kicker']?.toString(),
      meta: json['meta']?.toString(),
      imagePath: json['imagePath']?.toString(),
      detailUrl: json['detailUrl']?.toString(),
    );
  }
}

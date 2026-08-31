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

  SponsoredSlotsResponse({
    required this.success,
    this.whatsNew = const [],
    this.topTreks = const [],
    this.seasonalForecast = const [],
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
    );
  }
}

/// GET `/api/v1/discovery/search-sponsored?destination_id=`
///
/// The two search-results ad slots for a search:
///   { "data": { "listing": {...}|null, "banner": {...}|null } }
/// `listing` is a paid sponsored trek; `banner` is a brand ad shown after
/// every real result.
class SearchSponsoredResponse {
  final bool success;
  final SponsoredSlot? listing;
  final SponsoredSlot? banner;

  SearchSponsoredResponse({required this.success, this.listing, this.banner});

  factory SearchSponsoredResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    SponsoredSlot? one(dynamic raw) => raw is Map<String, dynamic>
        ? SponsoredSlot.fromJson(raw)
        : null;
    return SearchSponsoredResponse(
      success: json['success'] == true,
      listing: one(data['listing']),
      banner: one(data['banner']),
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

  // sponsored_trek
  final int? trekId;
  final String? title;
  final String? kicker;
  final String? meta;
  final String? imagePath;
  final String? detailUrl;

  // search_listing only — enough to render a full result card
  final String? vendorName;
  final String? duration;
  final String? price;
  final bool? hasDiscount;
  final double? rating;
  final String? batchStartDate;
  final int? batchId;

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
    this.vendorName,
    this.duration,
    this.price,
    this.hasDiscount,
    this.rating,
    this.batchStartDate,
    this.batchId,
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
      vendorName: json['vendorName']?.toString(),
      duration: json['duration']?.toString(),
      price: json['price']?.toString(),
      hasDiscount: json['hasDiscount'] as bool?,
      rating: (json['rating'] as num?)?.toDouble(),
      batchStartDate: json['batchStartDate']?.toString(),
      batchId: (json['batchId'] as num?)?.toInt(),
    );
  }
}

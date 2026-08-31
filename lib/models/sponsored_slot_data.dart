/// GET /api/v1/discovery/sponsored-slots
///
/// One creative per dashboard row, chosen server-side by weighted rotation:
///   { "data": { "whats_new": {...}|null, "top_treks": {...}|null,
///               "seasonal_forecast": {...}|null } }
class SponsoredSlotsResponse {
  final bool success;
  final SponsoredSlot? whatsNew;
  final SponsoredSlot? topTreks;
  final SponsoredSlot? seasonalForecast;

  SponsoredSlotsResponse({
    required this.success,
    this.whatsNew,
    this.topTreks,
    this.seasonalForecast,
  });

  factory SponsoredSlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return SponsoredSlotsResponse(
      success: json['success'] == true,
      whatsNew: data['whats_new'] is Map<String, dynamic>
          ? SponsoredSlot.fromJson(data['whats_new'] as Map<String, dynamic>)
          : null,
      topTreks: data['top_treks'] is Map<String, dynamic>
          ? SponsoredSlot.fromJson(data['top_treks'] as Map<String, dynamic>)
          : null,
      seasonalForecast: data['seasonal_forecast'] is Map<String, dynamic>
          ? SponsoredSlot.fromJson(
              data['seasonal_forecast'] as Map<String, dynamic>)
          : null,
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

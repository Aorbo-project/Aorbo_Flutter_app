/// Detail-screen data for a trek sourced from aorbotreks.com's own API
/// (`GET /api/treks/<id>/`) — a separate backend from ours, so this is a
/// plain model rather than freezed to avoid a build_runner regen for a
/// single-screen, one-off external shape.
class FeaturedDestinationDetail {
  final int? id;
  final String name;
  final String description;
  final String state;
  final String? priceStart;
  final String durationDays;
  final String operatingDays;
  final String mainImage;
  final List<String> activities;
  final List<String> famousPlaces;
  final List<String> operators;
  final List<RelatedTrek> relatedTreks;
  final double? latitude;
  final double? longitude;

  const FeaturedDestinationDetail({
    this.id,
    required this.name,
    required this.description,
    required this.state,
    this.priceStart,
    required this.durationDays,
    required this.operatingDays,
    required this.mainImage,
    required this.activities,
    required this.famousPlaces,
    required this.operators,
    required this.relatedTreks,
    this.latitude,
    this.longitude,
  });

  factory FeaturedDestinationDetail.fromJson(Map json) {
    final rawPrice = json['price_start'];
    return FeaturedDestinationDetail(
      id: json['id'] is int ? json['id'] as int : null,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      priceStart: (rawPrice == null || rawPrice.toString() == 'N/A')
          ? null
          : rawPrice.toString(),
      durationDays: json['duration_days']?.toString() ?? '3D/2N',
      operatingDays: json['operating_days']?.toString() ?? 'Thu, Fri, Sat',
      mainImage: json['main_image']?.toString() ?? '',
      activities: _stringList(json['activities']),
      famousPlaces: _stringList(json['famous_places']),
      operators: _stringList(json['operators']),
      relatedTreks: (json['related_treks'] is List)
          ? (json['related_treks'] as List)
              .whereType<Map>()
              .map(RelatedTrek.fromJson)
              .toList()
          : const [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}

class RelatedTrek {
  final int? id;
  final String name;
  final String state;

  const RelatedTrek({this.id, required this.name, required this.state});

  factory RelatedTrek.fromJson(Map json) {
    return RelatedTrek(
      id: json['id'] is int ? json['id'] as int : null,
      name: json['name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }
}

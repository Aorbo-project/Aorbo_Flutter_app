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

  /// Ready-to-show text from the server (`display.detail`, aorboweb display.py):
  /// shown as is, so wording changes need no app release. Null on an older server.
  final String? priceLabel;
  final List<DisplayFact> facts;

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
    this.priceLabel,
    this.facts = const [],
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
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      priceLabel: _displayDetail(json)?['price_label']?.toString(),
      facts: DisplayFact.listFrom(_displayDetail(json)?['facts']),
    );
  }

  static Map? _displayDetail(Map json) {
    final display = json['display'];
    final detail = display is Map ? display['detail'] : null;
    return detail is Map ? detail : null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  // A bare `as num?` throws on anything else (a stray "" or a malformed
  // string coordinate) — that used to fail parsing the ENTIRE response just
  // because of one bad coordinate field, not just leave lat/long unset.
  static double? _asDouble(dynamic value) => value is num ? value.toDouble() : null;
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

/// One row of pills on the trek detail screen ("Duration": ["3 Days / 2 Nights", ...]),
/// as the server sends it. New rows can be added on the server without an app release.
class DisplayFact {
  final String key;
  final String label;
  final List<String> options;

  const DisplayFact({required this.key, required this.label, required this.options});

  static List<DisplayFact> listFrom(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((m) => DisplayFact(
              key: m['key']?.toString() ?? '',
              label: m['label']?.toString() ?? '',
              options: (m['options'] is List)
                  ? (m['options'] as List).map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
                  : const <String>[],
            ))
        .where((f) => f.label.isNotEmpty && f.options.isNotEmpty)
        .toList();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../repository/network_url.dart';
import '../repository/repository.dart';
import '../theme/app_typography.dart';

/// The organiser's Google rating, read live by the server. Never saved on the
/// phone, and never mixed with Aorbo's own rating.
class GoogleRating {
  const GoogleRating({required this.rating, required this.count});

  final double rating;
  final int count;

  /// Anything malformed means nothing is shown.
  static GoogleRating? fromJson(Object? json) {
    if (json is! Map) return null;
    final rating = json['rating'];
    final count = json['count'];
    if (rating is! num || count is! int) return null;
    return GoogleRating(rating: rating.toDouble(), count: count);
  }
}

/// Google's policy: its rating must carry the "Google Maps" logo or, where space
/// is limited, this exact text (12-16sp, not localized, same container). The G
/// logo alone isn't allowed. This is the only place the attribution is drawn.
class GoogleMapsAttribution extends StatelessWidget {
  const GoogleMapsAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Google Maps',
      maxLines: 1,
      softWrap: false,
      textScaler: TextScaler.linear(1.0),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF5E5E5E)),
    );
  }
}

/// Ratings for the trek cards on screen. Cards ask as they appear, and one short
/// wait gathers them into a single call. Kept in memory for 10 minutes so scrolling
/// back doesn't spend another Google lookup.
class GoogleCardRatings {
  GoogleCardRatings._();

  static final GoogleCardRatings instance = GoogleCardRatings._();
  static const Duration _keepFor = Duration(minutes: 10);
  static const int _maxPerCall = 20;

  final Map<int, ({GoogleRating? rating, DateTime at})> _known = {};
  final Map<int, Completer<GoogleRating?>> _waiting = {};
  Timer? _timer;

  @visibleForTesting
  void seed(int trekId, GoogleRating? rating) => _known[trekId] = (rating: rating, at: DateTime.now());

  @visibleForTesting
  void clear() {
    _known.clear();
    _waiting.clear();
    _timer?.cancel();
    _timer = null;
  }

  Future<GoogleRating?> ratingFor(int trekId) {
    final known = _known[trekId];
    if (known != null && DateTime.now().difference(known.at) < _keepFor) {
      return SynchronousFuture(known.rating);
    }
    final completer = _waiting.putIfAbsent(trekId, Completer<GoogleRating?>.new);
    _timer ??= Timer(const Duration(milliseconds: 150), _send);
    return completer.future;
  }

  Future<void> _send() async {
    _timer = null;
    final batch = _waiting.keys.take(_maxPerCall).toList();
    final completers = {for (final id in batch) id: _waiting.remove(id)!};
    if (_waiting.isNotEmpty) _timer = Timer(Duration.zero, _send);

    Map<dynamic, dynamic> data = const {};
    try {
      final res = await Repository().getApiCall(url: '${NetworkUrl.getTrekDetail}google-ratings?ids=${batch.join(',')}');
      if (res is Map && res['data'] is Map) data = res['data'] as Map;
    } catch (_) {
      // Optional content: the card simply stays as it is.
    }
    completers.forEach((id, completer) {
      final rating = GoogleRating.fromJson(data['$id']);
      _known[id] = (rating: rating, at: DateTime.now());
      completer.complete(rating);
    });
  }
}

/// The trek page box. Rating and count only: no Google reviews.
class GoogleRatingBox extends StatelessWidget {
  const GoogleRatingBox({super.key, required this.data});

  final GoogleRating data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: const Color(0xFF6B7280).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const GoogleMapsAttribution(),
          const Spacer(),
          Icon(Icons.star_rounded, color: Colors.amber, size: 4.5.w),
          SizedBox(width: 1.w),
          Text(
            '${data.rating} (${data.count})',
            textScaler: const TextScaler.linear(1.0),
            style: AppType.style(10.0.sp, w: FontWeight.w700, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

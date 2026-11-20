import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../repository/network_url.dart';
import '../repository/repository.dart';

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

const String _googleGSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>
''';

/// G logo, rating and count (owner's choice, 3 Nov 2026). Google's policy asks for the
/// "Google Maps" logo or text, and doesn't mention the G alone: this one widget is the
/// only place to change if Google objects.
class GoogleRatingInline extends StatelessWidget {
  const GoogleRatingInline({super.key, required this.data, this.size = 14});

  final GoogleRating data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Google Maps rating ${data.rating}, ${data.count} ratings',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.string(_googleGSvg, width: size, height: size),
          SizedBox(width: size * 0.3),
          Text(
            '${data.rating}',
            maxLines: 1,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(fontSize: size * 0.93, fontWeight: FontWeight.w700, color: const Color(0xFF188038)),
          ),
          SizedBox(width: size * 0.2),
          Text(
            '(${data.count})',
            maxLines: 1,
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(fontSize: size * 0.86, fontWeight: FontWeight.w400, color: const Color(0xFF5E5E5E)),
          ),
        ],
      ),
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
      child: GoogleRatingInline(data: data, size: 16),
    );
  }
}

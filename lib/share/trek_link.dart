import 'dart:convert';

import 'package:intl/intl.dart';

import '../giveaway/giveaway_config.dart';
import '../utils/ist_date_utils.dart';
import '../utils/shared_preferences.dart';

/// A shared trek: `https://aorbotreks.co.in/t/<trekId>?b=<batchId>&c=<cityId>`.
///
/// The backend (routes/trekShareWeb.js) draws the preview card in chats and
/// sends people without the app to the Play Store with the same ids in the
/// install referrer (`trek=…&batch=…&city=…`). Everything parsed here is
/// untrusted input: only well-formed positive ids are kept, and the backend
/// still decides whether the trek is live.
class TrekLink {
  const TrekLink({required this.trekId, this.batchId, this.cityId});

  final int trekId;
  final int? batchId;
  final int? cityId;

  static final RegExp _idPattern = RegExp(r'^[1-9]\d{0,8}$');

  static int? _id(String? raw) {
    final v = raw?.trim();
    return (v != null && _idPattern.hasMatch(v)) ? int.parse(v) : null;
  }

  static int? _positive(int? v) => _id(v?.toString());

  /// The link for the share sheet; an unknown batch or city is left out.
  /// Null when [trekId] isn't a real id yet (screen still loading).
  static TrekLink? forShare({int? trekId, int? batchId, int? cityId}) {
    final id = _positive(trekId);
    if (id == null) return null;
    return TrekLink(trekId: id, batchId: _positive(batchId), cityId: _positive(cityId));
  }

  Uri toUri() {
    final query = [
      if (batchId != null) 'b=$batchId',
      if (cityId != null) 'c=$cityId',
    ].join('&');
    return Uri.parse(
        'https://${GiveawayConfig.shareLinkHost}/t/$trekId${query.isEmpty ? '' : '?$query'}');
  }

  /// `https://<Aorbo host>/t/<id>` (+ optional b/c) → link. Anything else → null.
  static TrekLink? fromUri(Uri uri) {
    if (uri.scheme != 'https') return null;
    if (!GiveawayConfig.referralLinkHosts.contains(uri.host.toLowerCase())) return null;
    if (uri.hasPort && uri.port != 443) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments[0] != 't') return null;
    final trekId = _id(segments[1]);
    if (trekId == null) return null;
    return TrekLink(
      trekId: trekId,
      batchId: _id(uri.queryParameters['b']),
      cityId: _id(uri.queryParameters['c']),
    );
  }

  /// Play install referrer ("trek=…&batch=…&city=…&utm_source=trek_share").
  static TrekLink? fromInstallReferrer(String? referrer) {
    if (referrer == null || referrer.isEmpty || referrer.length > 1024) return null;
    try {
      final q = Uri.splitQueryString(referrer);
      final trekId = _id(q['trek']);
      if (trekId == null) return null;
      return TrekLink(trekId: trekId, batchId: _id(q['batch']), cityId: _id(q['city']));
    } catch (_) {
      return null;
    }
  }

  /// Whether a batch's `YYYY-MM-DD` start date is before today in IST.
  static bool isPastDate(String? startDate, {DateTime? now}) {
    final start = ISTDateUtils.toIST(startDate);
    final today = ISTDateUtils.toIST(now ?? DateTime.now());
    if (start == null || today == null) return false;
    return DateTime.utc(start.year, start.month, start.day)
        .isBefore(DateTime.utc(today.year, today.month, today.day));
  }

  Map<String, dynamic> toJson() => {
        'trek': trekId,
        if (batchId != null) 'batch': batchId,
        if (cityId != null) 'city': cityId,
      };

  static TrekLink? fromJson(Object? json) {
    if (json is! Map) return null;
    final trekId = _positive(json['trek'] is int ? json['trek'] as int : null);
    if (trekId == null) return null;
    int? opt(Object? v) => _positive(v is int ? v : null);
    return TrekLink(trekId: trekId, batchId: opt(json['batch']), cityId: opt(json['city']));
  }

  @override
  bool operator ==(Object other) =>
      other is TrekLink && other.trekId == trekId && other.batchId == batchId && other.cityId == cityId;

  @override
  int get hashCode => Object.hash(trekId, batchId, cityId);

  @override
  String toString() => 'TrekLink(${toUri()})';
}

/// The message that goes with a shared trek. The link's preview card in the
/// chat carries the photo, price and organiser, so the text stays short.
class TrekShareText {
  TrekShareText._();

  static String build({required String title, String? startDate, required Uri link}) {
    final name = title.trim().isEmpty ? 'This trek' : title.trim();
    final start = ISTDateUtils.toIST(startDate);
    final when = start != null ? ' · ${DateFormat('E, d MMM yyyy').format(start)}' : '';
    return "Who's in? 🏔️\n"
        '$name$when\n'
        'Found it on Aorbo Treks 👇\n'
        '$link';
  }
}

/// A trek link that arrived before the person was signed in (tapped link or
/// Play install referrer). Held until the dashboard opens after login.
class PendingTrekLink {
  PendingTrekLink._();

  static const String _linkKey = 'pending_trek_link';
  static const String _savedAtKey = 'pending_trek_link_saved_at';
  static const Duration maxAge = Duration(days: 7);

  static Future<void> save(TrekLink link) async {
    final sp = await SpUtil.getInstance();
    await sp.putString(_linkKey, jsonEncode(link.toJson()));
    await sp.putInt(_savedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// The saved link, or null when there is none or it is older than [maxAge].
  static Future<TrekLink?> read() async {
    final sp = await SpUtil.getInstance();
    final raw = sp.getString(_linkKey);
    final savedAt = sp.getInt(_savedAtKey);
    if (raw == null || raw.isEmpty || savedAt == null) return null;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(savedAt));
    TrekLink? link;
    try {
      link = TrekLink.fromJson(jsonDecode(raw));
    } catch (_) {
      link = null;
    }
    if (link == null || age.isNegative || age > maxAge) {
      await clear();
      return null;
    }
    return link;
  }

  static Future<void> clear() async {
    final sp = await SpUtil.getInstance();
    await sp.remove(_linkKey);
    await sp.remove(_savedAtKey);
  }
}

import 'package:intl/intl.dart';

import '../giveaway/giveaway_config.dart';
import '../utils/ist_date_utils.dart';
import '../utils/shared_preferences.dart';

/// A shared trek: `https://aorbotreks.co.in/t/<code>`.
///
/// The code is opaque — only the backend (services/trekShareService.js) maps
/// it to a trek / batch / city, so a link never shows database ids. The
/// backend's `/t/<code>` page draws the preview card in chats and sends
/// people without the app to the Play Store with `share=<code>` in the
/// install referrer. Everything parsed here is untrusted input: only a
/// well-formed code is kept.
class TrekLink {
  const TrekLink(this.code);

  final String code;

  static final RegExp codePattern = RegExp(r'^[A-Za-z0-9]{8}$');

  static TrekLink? fromCode(String? raw) {
    final code = raw?.trim();
    return (code != null && codePattern.hasMatch(code)) ? TrekLink(code) : null;
  }

  Uri toUri() => Uri.parse('https://${GiveawayConfig.shareLinkHost}/t/$code');

  /// `https://<Aorbo host>/t/<code>` → link. Anything else → null.
  static TrekLink? fromUri(Uri uri) {
    if (uri.scheme != 'https') return null;
    if (!GiveawayConfig.referralLinkHosts.contains(uri.host.toLowerCase())) return null;
    if (uri.hasPort && uri.port != 443) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments[0] != 't') return null;
    return fromCode(segments[1]);
  }

  /// Play install referrer ("share=<code>&utm_source=trek_share").
  static TrekLink? fromInstallReferrer(String? referrer) {
    if (referrer == null || referrer.isEmpty || referrer.length > 1024) return null;
    try {
      return fromCode(Uri.splitQueryString(referrer)['share']);
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

  @override
  bool operator ==(Object other) => other is TrekLink && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'TrekLink($code)';
}

/// What a code points to, as the backend resolves it
/// (`GET share/treks/<code>` → `{trekId, batchId, cityId}`).
class TrekTarget {
  const TrekTarget({required this.trekId, this.batchId, this.cityId});

  final int trekId;
  final int? batchId;
  final int? cityId;

  static int? _id(Object? v) => (v is int && v > 0) ? v : null;

  static TrekTarget? fromJson(Object? json) {
    if (json is! Map) return null;
    final trekId = _id(json['trekId']);
    if (trekId == null) return null;
    return TrekTarget(trekId: trekId, batchId: _id(json['batchId']), cityId: _id(json['cityId']));
  }

  @override
  bool operator ==(Object other) =>
      other is TrekTarget && other.trekId == trekId && other.batchId == batchId && other.cityId == cityId;

  @override
  int get hashCode => Object.hash(trekId, batchId, cityId);
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

  static const String _codeKey = 'pending_trek_link_code';
  static const String _savedAtKey = 'pending_trek_link_saved_at';
  static const Duration maxAge = Duration(days: 7);

  static Future<void> save(TrekLink link) async {
    final sp = await SpUtil.getInstance();
    await sp.putString(_codeKey, link.code);
    await sp.putInt(_savedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// The saved link, or null when there is none or it is older than [maxAge].
  static Future<TrekLink?> read() async {
    final sp = await SpUtil.getInstance();
    final link = TrekLink.fromCode(sp.getString(_codeKey));
    final savedAt = sp.getInt(_savedAtKey);
    if (link == null || savedAt == null) {
      if (link == null && savedAt != null) await clear();
      return null;
    }
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(savedAt));
    if (age.isNegative || age > maxAge) {
      await clear();
      return null;
    }
    return link;
  }

  static Future<void> clear() async {
    final sp = await SpUtil.getInstance();
    await sp.remove(_codeKey);
    await sp.remove(_savedAtKey);
  }
}

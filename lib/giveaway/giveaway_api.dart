import '../repository/network_url.dart';
import '../repository/referral_repository.dart';
import '../repository/repository.dart';
import 'giveaway_bridge.dart';
import 'giveaway_config.dart';

/// Outcome of an entry request, passed back to the web page as-is.
class EntryResult {
  const EntryResult.ok(this.data)
      : ok = true,
        errorCode = null,
        errorMessage = null;
  const EntryResult.failed(this.errorCode, this.errorMessage)
      : ok = false,
        data = const {};

  final bool ok;
  final Map<String, Object?> data;
  final String? errorCode;
  final String? errorMessage;
}

/// What the dashboard banner needs about the featured round.
class GiveawayRoundSummary {
  const GiveawayRoundSummary({
    required this.code,
    required this.label,
    required this.phase,
    required this.drawAt,
  });

  final String code;
  final String label;
  final String phase;
  final DateTime drawAt;

  static GiveawayRoundSummary? fromJson(Object? json) {
    if (json is! Map) return null;
    final drawAt = DateTime.tryParse('${json['drawAt']}');
    if (json['code'] is! String || json['label'] is! String || drawAt == null) return null;
    return GiveawayRoundSummary(
      code: json['code'] as String,
      label: json['label'] as String,
      phase: '${json['phase']}',
      drawAt: drawAt,
    );
  }

  /// "Draw on 31 Mar, 7 PM" — always India time, whatever the phone's zone.
  String get drawLabel {
    final ist = drawAt.toUtc().add(const Duration(hours: 5, minutes: 30));
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h12 = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
    final ampm = ist.hour < 12 ? 'AM' : 'PM';
    final time = ist.minute == 0 ? '$h12 $ampm' : '$h12:${ist.minute.toString().padLeft(2, '0')} $ampm';
    final when = '${ist.day} ${months[ist.month - 1]}, $time';
    return phase == 'drawn' ? 'Drawn on ${ist.day} ${months[ist.month - 1]}' : 'Draw on $when';
  }
}

class GiveawayRulesSection {
  const GiveawayRulesSection(this.title, this.paragraphs);
  final String title;
  final List<String> paragraphs;
}

/// The round's official rules, as frozen on the server.
class GiveawayRules {
  const GiveawayRules({required this.label, required this.version, required this.sections});
  final String label;
  final String version;
  final List<GiveawayRulesSection> sections;

  static GiveawayRules? fromJson(Object? json) {
    if (json is! Map || json['sections'] is! List) return null;
    final sections = <GiveawayRulesSection>[];
    for (final s in json['sections'] as List) {
      if (s is! Map || s['title'] is! String || s['paragraphs'] is! List) continue;
      sections.add(GiveawayRulesSection(
        s['title'] as String,
        (s['paragraphs'] as List).whereType<String>().toList(),
      ));
    }
    if (sections.isEmpty) return null;
    return GiveawayRules(
      label: '${json['label'] ?? ''}',
      version: '${json['version'] ?? ''}',
      sections: sections,
    );
  }
}

/// The giveaway's backend calls, as the app sees them.
///
/// Preview builds (--dart-define=GIVEAWAY_PREVIEW=true) use sample data so the
/// design can be reviewed without a live round; everything else talks to the
/// backend (routes/v1/giveawayRoutes.js).
abstract class GiveawayApi {
  static GiveawayApi instance = GiveawayConfig.isPreview ? PreviewGiveawayApi() : RemoteGiveawayApi();

  /// One-time code that signs the web page in (60 s, single use).
  /// Null when there is none — the page then shows its public view.
  Future<String?> createWebCode();

  Future<EntryResult> submitEntry({required String requestId, required EntrySubmission entry});

  /// The signed-in user's own referral code, for the share sheet.
  Future<String?> myReferralCode();

  /// The round the dashboard banner advertises; null when there is none.
  Future<GiveawayRoundSummary?> currentRound();

  /// Official rules — of [round] when given, else the signed-in person's own
  /// round (the backend decides).
  Future<GiveawayRules?> rules({String? round});
}

class RemoteGiveawayApi implements GiveawayApi {
  RemoteGiveawayApi({Repository? repository}) : _repo = repository ?? Repository();
  final Repository _repo;

  @override
  Future<String?> createWebCode() async {
    final reply = await _repo.postForReply(url: NetworkUrl.giveawayWebCode, body: <String, dynamic>{});
    if (!reply.ok) return null;
    final data = reply.json['data'];
    final code = data is Map ? data['code'] : null;
    return code is String && code.isNotEmpty ? code : null;
  }

  @override
  Future<EntryResult> submitEntry({required String requestId, required EntrySubmission entry}) async {
    final reply = await _repo.postForReply(
      url: NetworkUrl.giveawayEntries,
      body: entry.toJson(),
      headers: {'Idempotency-Key': requestId},
    );
    final json = reply.json;
    if (reply.ok && json['data'] is Map) {
      final data = json['data'] as Map;
      return EntryResult.ok({'entryNumber': '${data['entryNumber']}', 'status': '${data['status']}'});
    }
    return EntryResult.failed(
      json['code'] is String ? json['code'] as String : 'error',
      json['message'] is String ? json['message'] as String : "Couldn't send your entry. Please try again.",
    );
  }

  @override
  Future<String?> myReferralCode() async {
    final info = await ReferralRepository().getReferralInfo();
    final code = info.code;
    return (code == null || code.isEmpty) ? null : code;
  }

  @override
  Future<GiveawayRoundSummary?> currentRound() async {
    final res = await _repo.getApiCall(url: NetworkUrl.giveawayCurrent);
    final data = res is Map ? res['data'] : null;
    return GiveawayRoundSummary.fromJson(data is Map ? data['round'] : null);
  }

  @override
  Future<GiveawayRules?> rules({String? round}) async {
    final url = round == null ? NetworkUrl.giveawayRules : '${NetworkUrl.giveawayRules}?round=${Uri.encodeQueryComponent(round)}';
    final res = await _repo.getApiCall(url: url);
    return GiveawayRules.fromJson(res is Map ? res['data'] : null);
  }
}

/// Sample data for design-review builds. No network except the referral code.
class PreviewGiveawayApi implements GiveawayApi {
  @override
  Future<String?> createWebCode() async => null;

  @override
  Future<EntryResult> submitEntry({required String requestId, required EntrySubmission entry}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const EntryResult.ok({'entryNumber': '01842', 'status': 'valid'});
  }

  @override
  Future<String?> myReferralCode() async {
    final info = await ReferralRepository().getReferralInfo();
    final code = info.code;
    return (code == null || code.isEmpty) ? null : code;
  }

  @override
  Future<GiveawayRoundSummary?> currentRound() async => GiveawayRoundSummary(
        code: 'R1',
        label: 'Round 1',
        phase: 'open',
        drawAt: DateTime.utc(2027, 3, 31, 13, 30),
      );

  @override
  Future<GiveawayRules?> rules({String? round}) async => const GiveawayRules(
        label: 'Round 1',
        version: 'preview',
        sections: [
          GiveawayRulesSection('1. The giveaway', [
            'Sample rules for the design preview. The real rules load from the server, frozen for each round.',
          ]),
          GiveawayRulesSection('2. Who can enter', ['• 18 or older, living in India', '• New to Aorbo']),
        ],
      );
}

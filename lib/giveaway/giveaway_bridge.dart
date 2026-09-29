import 'dart:convert';

/// Message protocol between the giveaway web page and the app.
///
/// Page → app, via the `AorboGiveaway` JavaScript channel:
///   `{"v":1, "id":"<request id>", "type":"<type>", "payload":{...}}`
/// App → page, via `window.AorboGiveawayHost.receive('<json>')`:
///   `{"v":1, "replyTo":"<request id>", "type":"<type>", "ok":true|false,`
///   ` "data":{...}, "error":{"code":"...", "message":"..."}}`
///
/// Messages are REQUESTS, never facts. The app checks their shape here and
/// then asks the backend with its own login + Play Integrity token; the
/// backend checks the content (the round's questions, eligibility, the rules
/// version) and decides. A malformed message is dropped — except an entry
/// with a valid id, which gets an `invalid_request` reply so the page never
/// waits in silence. Limits match the backend's (roundService.validateContent).
class GiveawayBridge {
  GiveawayBridge._();

  static const String channelName = 'AorboGiveaway';
  static const int protocolVersion = 1;
  static const int maxMessageLength = 16 * 1024;

  static final RegExp _id = RegExp(r'^[A-Za-z0-9-]{8,64}$');
  static final RegExp _roundCode = RegExp(r'^[A-Z0-9-]{2,16}$');

  /// Parses one raw channel message. Returns null for anything malformed.
  static BridgeRequest? parse(String raw) {
    if (raw.isEmpty || raw.length > maxMessageLength) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['v'] != protocolVersion) return null;
    final id = decoded['id'];
    if (id is! String || !_id.hasMatch(id)) return null;
    final type = BridgeRequestType.fromWire(decoded['type']);
    if (type == null) return null;
    final payload = decoded['payload'] ?? const <String, dynamic>{};
    if (payload is! Map<String, dynamic>) return null;

    if (type == BridgeRequestType.submitEntry) {
      final entry = EntrySubmission.fromPayload(payload);
      return BridgeRequest(id: id, type: type, entry: entry, invalid: entry == null);
    }
    if (type == BridgeRequestType.openRules) {
      final round = payload['round'];
      return BridgeRequest(
        id: id,
        type: type,
        round: round is String && _roundCode.hasMatch(round) ? round : null,
      );
    }
    return BridgeRequest(id: id, type: type);
  }

  /// JavaScript that hands [reply] to the page. The JSON is passed as a JS
  /// string literal and parsed by the page, so nothing in it runs as code.
  static String replyScript(Map<String, Object?> reply) {
    final json = jsonEncode({'v': protocolVersion, ...reply});
    return 'window.AorboGiveawayHost && window.AorboGiveawayHost.receive(${jsonEncode(json)});';
  }
}

enum BridgeRequestType {
  /// The page has rendered; the app can hide its own loading screen.
  ready('ready'),

  /// Open the official rules (a native screen, so they stay reachable even
  /// if the page breaks) — of the round in `payload.round` when given.
  openRules('openRules'),

  /// Open the phone's share sheet with the user's own referral link. The app
  /// writes the message itself; the page can't choose what gets shared.
  share('share'),

  /// Send the survey answers + rules acceptance as a giveaway entry.
  submitEntry('submitEntry'),

  /// Close the giveaway screen.
  close('close'),

  /// The page's web session ended (30 min, or a login elsewhere): sign it in
  /// again with a fresh one-time code (the app reloads it).
  refreshSession('refreshSession');

  const BridgeRequestType(this.wire);
  final String wire;

  static BridgeRequestType? fromWire(Object? value) {
    for (final t in values) {
      if (t.wire == value) return t;
    }
    return null;
  }
}

class BridgeRequest {
  const BridgeRequest({required this.id, required this.type, this.entry, this.round, this.invalid = false});

  /// Also used as the entry request's Idempotency-Key, so a double tap
  /// creates one entry.
  final String id;
  final BridgeRequestType type;
  final EntrySubmission? entry;

  /// openRules: the round code the page is showing.
  final String? round;

  /// submitEntry whose payload failed the shape checks.
  final bool invalid;
}

/// Shape-checked entry. The answers are forwarded as they are; which
/// questions exist and which options are valid is the backend's call (the
/// questions are data per round, so they can change without an app release).
class EntrySubmission {
  const EntrySubmission({
    required this.answers,
    required this.rulesVersion,
    required this.publicityConsent,
    this.stateId,
  });

  final Map<String, Object> answers;
  final String rulesVersion;
  final bool publicityConsent;

  /// The state the person lives in — sent only when their profile has none
  /// and the round excludes some states. The backend checks it exists.
  final int? stateId;

  static const int maxAnswers = 12;
  static const int maxTextLength = 1000;
  static const int maxChoices = 12;
  static const int maxChoiceLength = 64;

  static final RegExp _questionKey = RegExp(r'^[a-z0-9_]{1,24}$');
  static final RegExp _rulesVersion = RegExp(r'^[A-Za-z0-9._-]{1,32}$');
  // Control characters other than tab and newline.
  static final RegExp _control = RegExp(r'[\u0000-\u0008\u000B-\u001F\u007F]');

  static EntrySubmission? fromPayload(Map<String, dynamic> payload) {
    // Both ticks are required by the rules; the backend checks them again.
    if (payload['rulesAccepted'] != true) return null;
    if (payload['declaredAdult'] != true) return null;
    final version = payload['rulesVersion'];
    if (version is! String || !_rulesVersion.hasMatch(version)) return null;
    final publicity = payload['publicityConsent'] ?? false;
    if (publicity is! bool) return null;
    final stateId = payload['stateId'];
    if (stateId != null && (stateId is! int || stateId <= 0 || stateId > 1000000)) return null;

    final raw = payload['answers'];
    if (raw is! Map<String, dynamic> || raw.isEmpty || raw.length > maxAnswers) return null;
    final answers = <String, Object>{};
    for (final e in raw.entries) {
      if (!_questionKey.hasMatch(e.key)) return null;
      final v = e.value;
      if (v is String) {
        final text = v.trim();
        if (text.length > maxTextLength || _control.hasMatch(text)) return null;
        answers[e.key] = text;
      } else if (v is List) {
        if (v.isEmpty || v.length > maxChoices) return null;
        final choices = <String>[];
        for (final c in v) {
          if (c is! String || c.isEmpty || c.length > maxChoiceLength || _control.hasMatch(c)) {
            return null;
          }
          choices.add(c);
        }
        answers[e.key] = choices;
      } else {
        return null;
      }
    }
    return EntrySubmission(
      answers: answers,
      rulesVersion: version,
      publicityConsent: publicity,
      stateId: stateId as int?,
    );
  }

  Map<String, Object> toJson() => {
        'answers': answers,
        'rulesAccepted': true,
        'declaredAdult': true,
        'rulesVersion': rulesVersion,
        'publicityConsent': publicityConsent,
        if (stateId != null) 'stateId': stateId!,
      };
}

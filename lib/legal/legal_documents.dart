// Customer legal documents (Terms, Privacy Policy, ...) — the data and the
// pure rules. No Flutter, no network, no prefs: everything here is plain
// functions so it can be unit-tested (test/legal/).
//
// Backend contract (all under /api/v1):
//   GET  legal/documents         public  → {data:{documents:[LegalDocument]}}
//   GET  customer/legal/status   JWT     → {data:{needsAcceptance, documents:[...]}}
//   POST customer/legal/accept   JWT     → 200 same shape as status, or
//        409 {code:"LEGAL_VERSION_OUTDATED", data:{documents:[current list]}}
//
// Keys, titles, URLs and versions always come from the server. The only
// hardcoded copy is [fallbackLegalDocuments] — titles + URLs, NO versions —
// used to open a link when the list has never been loaded (offline).

/// Document keys the app refers to by name.
class LegalDocKeys {
  LegalDocKeys._();
  static const String terms = 'terms';
  static const String privacy = 'privacy';
  static const String userAgreement = 'user_agreement';
  static const String refund = 'refund';
}

/// One legal document as the server describes it.
class LegalDocument {
  const LegalDocument({
    required this.key,
    required this.title,
    required this.url,
    this.version,
    this.requiresAcceptance = false,
  });

  final String key;
  final String title;
  final String url;

  /// Current version on the server. Null only for [fallbackLegalDocuments].
  final String? version;

  /// True when the customer must agree to it (Terms, Privacy Policy).
  final bool requiresAcceptance;

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'url': url,
        if (version != null) 'version': version,
        'requiresAcceptance': requiresAcceptance,
      };

  @override
  bool operator ==(Object other) =>
      other is LegalDocument &&
      other.key == key &&
      other.title == title &&
      other.url == url &&
      other.version == version &&
      other.requiresAcceptance == requiresAcceptance;

  @override
  int get hashCode => Object.hash(key, title, url, version, requiresAcceptance);

  @override
  String toString() => 'LegalDocument($key v$version${requiresAcceptance ? ', required' : ''})';
}

/// Offline fallback — titles + URLs only, never versions, so nothing can
/// ever be "accepted" from this list. Used only to open a link.
const List<LegalDocument> fallbackLegalDocuments = [
  LegalDocument(
    key: LegalDocKeys.terms,
    title: 'Terms & Conditions',
    url: 'https://aorbotreks.com/terms',
  ),
  LegalDocument(
    key: LegalDocKeys.privacy,
    title: 'Privacy Policy',
    url: 'https://aorbotreks.com/privacy-policy',
  ),
  LegalDocument(
    key: LegalDocKeys.userAgreement,
    title: 'User Agreement',
    url: 'https://aorbotreks.com/user-agreement',
  ),
  LegalDocument(
    key: LegalDocKeys.refund,
    title: 'Refund & Cancellation Policy',
    url: 'https://aorbotreks.com/refund-policy',
  ),
];

String? _nonEmptyString(Object? v) {
  if (v is! String) return null;
  final s = v.trim();
  return s.isEmpty ? null : s;
}

/// Only http(s) links are ever opened — a malformed or `javascript:`/`intent:`
/// URL from a bad reply is dropped.
bool isOpenableLegalUrl(String? url) {
  if (url == null) return false;
  final uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
}

/// Finds the `documents` list in a reply: the whole body
/// `{success, data:{documents}}`, the `data` map, or the list itself.
List<Object?>? _documentsList(Object? body) {
  if (body is List) return body;
  if (body is! Map) return null;
  final data = body['data'];
  if (data is Map && data['documents'] is List) return data['documents'] as List;
  if (body['documents'] is List) return body['documents'] as List;
  return null;
}

/// Parses a document list. Entries without a key, title or openable URL are
/// skipped; a repeated key keeps the first. When an entry doesn't say whether
/// it [LegalDocument.requiresAcceptance], the value is taken from the
/// same-key document in [inheritFrom] (else false).
List<LegalDocument> parseLegalDocuments(
  Object? body, {
  List<LegalDocument> inheritFrom = const [],
}) {
  final raw = _documentsList(body);
  if (raw == null) return const [];
  final known = {for (final d in inheritFrom) d.key: d};
  final seen = <String>{};
  final out = <LegalDocument>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final key = _nonEmptyString(e['key']);
    final title = _nonEmptyString(e['title']);
    final url = _nonEmptyString(e['url']);
    if (key == null || title == null || !isOpenableLegalUrl(url)) continue;
    if (!seen.add(key)) continue;
    final req = e['requiresAcceptance'];
    out.add(LegalDocument(
      key: key,
      title: title,
      url: url!,
      version: _nonEmptyString(e['version']),
      requiresAcceptance: req is bool ? req : (known[key]?.requiresAcceptance ?? false),
    ));
  }
  return out;
}

/// [known] with every document in [updates] applied on top (same key →
/// replaced, new key → appended). Used for a 409's "current list" and for
/// the versions a status reply carries.
List<LegalDocument> mergeLegalDocuments(List<LegalDocument> known, List<LegalDocument> updates) {
  final byKey = <String, LegalDocument>{for (final u in updates) u.key: u};
  final out = <LegalDocument>[];
  for (final k in known) {
    out.add(byKey.remove(k.key) ?? k);
  }
  for (final u in updates) {
    final added = byKey.remove(u.key);
    if (added != null) out.add(added);
  }
  return out;
}

/// What the Profile "Legal" group lists: the server's list, or the fallback.
List<LegalDocument> documentsForDisplay(List<LegalDocument> loaded) =>
    loaded.isNotEmpty ? loaded : fallbackLegalDocuments;

/// URL to open for [key]: the server's, else the fallback's, else null.
String? legalUrlFor(String key, List<LegalDocument> loaded) {
  for (final d in loaded) {
    if (d.key == key && isOpenableLegalUrl(d.url)) return d.url;
  }
  for (final d in fallbackLegalDocuments) {
    if (d.key == key) return d.url;
  }
  return null;
}

/// One document's line in a status reply.
class LegalDocStatus {
  const LegalDocStatus({
    required this.key,
    required this.title,
    required this.url,
    required this.version,
    required this.acceptedVersion,
    required this.needsAcceptance,
  });

  final String key;
  final String title;
  final String url;
  final String? version;
  final String? acceptedVersion;
  final bool needsAcceptance;
}

/// GET customer/legal/status (and a successful accept) — parsed.
class LegalStatus {
  const LegalStatus({required this.needsAcceptance, required this.documents});

  final bool needsAcceptance;
  final List<LegalDocStatus> documents;

  /// Accepts the whole reply body or its `data` map. Null when malformed.
  static LegalStatus? fromJson(Object? body) {
    if (body is! Map) return null;
    final data = body['data'] is Map ? body['data'] as Map : body;
    final needs = data['needsAcceptance'];
    if (needs is! bool) return null;
    final docs = <LegalDocStatus>[];
    final raw = data['documents'];
    if (raw is List) {
      for (final e in raw) {
        if (e is! Map) continue;
        final key = _nonEmptyString(e['key']);
        if (key == null) continue;
        docs.add(LegalDocStatus(
          key: key,
          title: _nonEmptyString(e['title']) ?? key,
          url: _nonEmptyString(e['url']) ?? '',
          version: _nonEmptyString(e['version']),
          acceptedVersion: _nonEmptyString(e['acceptedVersion']),
          needsAcceptance: e['needsAcceptance'] == true,
        ));
      }
    }
    return LegalStatus(needsAcceptance: needs, documents: docs);
  }

  /// The status documents that carry a usable title + URL, as
  /// [LegalDocument]s — so their versions can refresh the cached list.
  List<LegalDocument> asDocuments(List<LegalDocument> known) {
    final knownByKey = {for (final d in known) d.key: d};
    return [
      for (final s in documents)
        if (isOpenableLegalUrl(s.url))
          LegalDocument(
            key: s.key,
            title: s.title,
            url: s.url,
            version: s.version,
            requiresAcceptance: knownByKey[s.key]?.requiresAcceptance ?? s.needsAcceptance,
          ),
    ];
  }
}

/// The `documents` array for POST customer/legal/accept: every document that
/// requires acceptance, at its current version. A document the status says
/// still needs acceptance but that the list doesn't have is added from the
/// status (so a stale list can't loop the prompt forever). A document with no
/// known version is never sent.
List<Map<String, String>> documentsToAccept(
  List<LegalDocument> docs, {
  LegalStatus? status,
}) {
  final out = <Map<String, String>>[];
  final seen = <String>{};
  for (final d in docs) {
    final v = d.version;
    if (!d.requiresAcceptance || v == null || v.isEmpty) continue;
    if (seen.add(d.key)) out.add({'key': d.key, 'version': v});
  }
  for (final s in status?.documents ?? const <LegalDocStatus>[]) {
    final v = s.version;
    if (!s.needsAcceptance || v == null || v.isEmpty) continue;
    if (seen.add(s.key)) out.add({'key': s.key, 'version': v});
  }
  return out;
}

/// Where an acceptance came from — the backend's `source` values.
class LegalAcceptSource {
  LegalAcceptSource._();
  static const String login = 'login';
  static const String updatePrompt = 'update_prompt';
}

/// Full POST body.
Map<String, dynamic> buildAcceptBody(
  List<Map<String, String>> documents, {
  required String source,
  String? appVersion,
}) =>
    {
      'documents': documents,
      'source': source,
      if (appVersion != null && appVersion.isNotEmpty) 'appVersion': appVersion,
    };

/// "1.0.0+22" — the pubspec version, from PackageInfo's two halves.
String? pubspecVersion(String? version, String? buildNumber) {
  if (version == null || version.isEmpty) return null;
  return (buildNumber == null || buildNumber.isEmpty) ? version : '$version+$buildNumber';
}

enum LegalAcceptOutcome {
  /// Recorded. [LegalAcceptResult.status] holds the new status.
  accepted,

  /// 409 LEGAL_VERSION_OUTDATED — a document changed; the current list is in
  /// [LegalAcceptResult.currentDocuments]. Show the prompt again.
  outdated,

  /// Anything else (network, 4xx, 5xx, nothing to send).
  failed,
}

class LegalAcceptResult {
  const LegalAcceptResult._(this.outcome, {this.status, this.currentDocuments = const [], this.message});

  const LegalAcceptResult.accepted(LegalStatus? status) : this._(LegalAcceptOutcome.accepted, status: status);

  const LegalAcceptResult.outdated(List<LegalDocument> current)
      : this._(LegalAcceptOutcome.outdated, currentDocuments: current);

  const LegalAcceptResult.failed(String message) : this._(LegalAcceptOutcome.failed, message: message);

  final LegalAcceptOutcome outcome;
  final LegalStatus? status;
  final List<LegalDocument> currentDocuments;
  final String? message;

  bool get isAccepted => outcome == LegalAcceptOutcome.accepted;
}

const String legalVersionOutdatedCode = 'LEGAL_VERSION_OUTDATED';
const String legalAcceptGenericError = "Couldn't save your agreement. Please try again.";
const String legalAcceptNetworkError = "Couldn't reach Aorbo. Check your internet connection and try again.";

/// Reads the accept reply. [known] fills in `requiresAcceptance` for a 409
/// list that leaves it out.
LegalAcceptResult interpretAcceptReply(
  int statusCode,
  Object? body, {
  List<LegalDocument> known = const [],
}) {
  final json = body is Map ? body : const {};
  if (statusCode >= 200 && statusCode < 300 && json['success'] == true) {
    return LegalAcceptResult.accepted(LegalStatus.fromJson(json));
  }
  if (statusCode == 409 && json['code'] == legalVersionOutdatedCode) {
    return LegalAcceptResult.outdated(parseLegalDocuments(json, inheritFrom: known));
  }
  final msg = _nonEmptyString(json['message']);
  return LegalAcceptResult.failed(msg ?? legalAcceptGenericError);
}

/// The documents the update prompt links to: those the status says need
/// acceptance; if it names none, every document that requires acceptance.
List<LegalDocument> documentsForPrompt(LegalStatus status, List<LegalDocument> loaded) {
  final pending = <LegalDocument>[];
  for (final s in status.documents.where((s) => s.needsAcceptance)) {
    final url = isOpenableLegalUrl(s.url) ? s.url : legalUrlFor(s.key, loaded);
    if (url == null) continue;
    pending.add(LegalDocument(key: s.key, title: s.title, url: url, version: s.version, requiresAcceptance: true));
  }
  if (pending.isNotEmpty) return pending;
  final required = loaded.where((d) => d.requiresAcceptance).toList();
  if (required.isNotEmpty) return required;
  return fallbackLegalDocuments
      .where((d) => d.key == LegalDocKeys.terms || d.key == LegalDocKeys.privacy)
      .toList();
}

/// Whether to show the "We've updated our terms" sheet now.
bool shouldShowLegalPrompt({
  required bool loggedIn,
  required LegalStatus? status,
  required bool alreadyShownThisSession,
}) =>
    loggedIn && !alreadyShownThisSession && status != null && status.needsAcceptance;

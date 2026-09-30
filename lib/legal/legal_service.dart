import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:arobo_app/main.dart';
import 'package:arobo_app/services/app_feedback.dart';
import 'package:arobo_app/utils/shared_preferences.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'legal_api.dart';
import 'legal_documents.dart';

/// Opens a legal document (by server key: 'terms', 'privacy', ...) in the
/// browser. Uses the server's URL; falls back to the built-in one when the
/// list has never loaded (offline).
Future<void> openLegalDoc(String key) async {
  final url = LegalService.instance.urlFor(key);
  if (url == null) {
    AppFeedback.error("Couldn't open this page right now. Please try again.");
    return;
  }
  await openLegalUrl(url);
}

/// Opens [url] (already validated as http/https) in the browser.
Future<void> openLegalUrl(String url) async {
  if (!isOpenableLegalUrl(url)) return;
  final uri = Uri.parse(url);
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) AppFeedback.error("Couldn't open this page. Please try again.");
  } catch (_) {
    AppFeedback.error("Couldn't open this page. Please try again.");
  }
}

/// Customer legal documents: the list (memory + prefs cache), agreement at
/// sign-in, and the "we've updated our terms" check. See legal_documents.dart
/// for the backend contract and the pure rules this delegates to.
///
/// A plain singleton (not a GetxController) on purpose: logout runs
/// Get.deleteAll, and the list + "already prompted" memory should outlive it.
class LegalService {
  @visibleForTesting
  LegalService({
    LegalApi? api,
    Future<String?> Function()? appVersion,
    bool Function()? isLoggedIn,
    int? Function()? currentUserId,
  })  : _apiOverride = api,
        _appVersion = appVersion ?? _pubspecVersionFromPlatform,
        _isLoggedIn = isLoggedIn ?? (() => sp?.getBool(SpUtil.isLoggedIn) == true),
        _currentUserId = currentUserId ?? (() => sp?.getInt(SpUtil.userID));

  static LegalService instance = LegalService();

  final LegalApi? _apiOverride;
  LegalApi? _remote;
  LegalApi get _api => _apiOverride ?? (_remote ??= RemoteLegalApi());

  final Future<String?> Function() _appVersion;
  final bool Function() _isLoggedIn;
  final int? Function() _currentUserId;

  /// Current documents — server list, or the cached copy until it arrives.
  /// Empty until either exists; UI then uses [fallbackLegalDocuments].
  final RxList<LegalDocument> documents = <LegalDocument>[].obs;

  bool _loadedFromServer = false;
  Future<bool>? _refreshInFlight;
  Future<void>? _loginAcceptance;
  LegalStatus? _lastStatus;

  bool _promptChecking = false;
  bool _prompted = false;
  int? _promptedUser;

  bool get isLoggedIn => _isLoggedIn();

  /// True once a list has come from the server during this app run.
  bool get loadedFromServer => _loadedFromServer;

  static Future<String?> _pubspecVersionFromPlatform() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return pubspecVersion(info.version, info.buildNumber);
    } catch (_) {
      return null;
    }
  }

  // ── Document list ─────────────────────────────────────────────────────

  /// App start: the cached list now, a fresh one in the background.
  void warmUp() {
    loadCached();
    unawaited(refresh());
  }

  /// Fills [documents] from the prefs cache if nothing is loaded yet.
  void loadCached() {
    if (documents.isNotEmpty) return;
    try {
      final raw = sp?.getString(SpUtil.legalDocuments);
      if (raw is! String || raw.isEmpty) return;
      final docs = parseLegalDocuments(jsonDecode(raw));
      if (docs.isNotEmpty) documents.assignAll(docs);
    } catch (e) {
      log('legal: cached list unreadable: $e');
    }
  }

  /// Fetches the list from the server (one request at a time). True when a
  /// usable list arrived; false (silently) on any failure.
  Future<bool> refresh() {
    return _refreshInFlight ??= _fetchDocuments().whenComplete(() => _refreshInFlight = null);
  }

  /// A server list this app run — fetched now if there isn't one yet.
  Future<bool> ensureLoaded() async => _loadedFromServer || await refresh();

  Future<bool> _fetchDocuments() async {
    try {
      final docs = parseLegalDocuments(await _api.fetchDocuments(), inheritFrom: documents);
      if (docs.isEmpty) return false;
      await _store(docs);
      _loadedFromServer = true;
      return true;
    } catch (e) {
      log('legal: document list fetch failed: $e');
      return false;
    }
  }

  Future<void> _store(List<LegalDocument> docs) async {
    documents.assignAll(docs);
    try {
      await sp?.putString(SpUtil.legalDocuments, jsonEncode(docs.map((d) => d.toJson()).toList()));
    } catch (_) {}
  }

  /// URL for [key]: the server's, else the built-in fallback.
  String? urlFor(String key) => legalUrlFor(key, documents);

  // ── Agreement ─────────────────────────────────────────────────────────

  /// Records agreement to every document that requires it, at its current
  /// version. Fetches the list first when none came from the server yet.
  /// Never throws: failures come back as [LegalAcceptOutcome.failed]. On a
  /// 409 the current list replaces the stale one, so the next call sends the
  /// right versions.
  Future<LegalAcceptResult> acceptCurrent(String source) async {
    try {
      if (!_loadedFromServer) await refresh();
      final docs = documentsToAccept(documents, status: _lastStatus);
      if (docs.isEmpty) return const LegalAcceptResult.failed(legalAcceptNetworkError);
      final body = buildAcceptBody(docs, source: source, appVersion: await _appVersion());
      final reply = await _api.accept(body);
      final result = interpretAcceptReply(reply.statusCode, reply.data, known: documents);
      switch (result.outcome) {
        case LegalAcceptOutcome.accepted:
          _lastStatus = result.status;
        case LegalAcceptOutcome.outdated:
          _lastStatus = null;
          if (result.currentDocuments.isNotEmpty) {
            await _store(mergeLegalDocuments(documents, result.currentDocuments));
          } else {
            await refresh();
          }
        case LegalAcceptOutcome.failed:
          break;
      }
      return result;
    } catch (e) {
      log('legal: accept ($source) failed: $e');
      return const LegalAcceptResult.failed(legalAcceptNetworkError);
    }
  }

  /// Right after a successful OTP sign-in: the sign-in screen says "By
  /// continuing, you agree to our Terms & Conditions and Privacy Policy", so
  /// record that. Fire and forget — never blocks or fails the login; on any
  /// error it gives up and the dashboard's status check catches up.
  void recordLoginAcceptance() {
    try {
      _lastStatus = null; // never carry a previous account's status over
      final pending = acceptCurrent(LegalAcceptSource.login).then<void>((r) {
        if (!r.isAccepted) log('legal: sign-in agreement not recorded (${r.outcome.name})');
      }, onError: (Object e) => log('legal: sign-in agreement failed: $e'));
      _loginAcceptance = pending;
      unawaited(pending.whenComplete(() {
        if (identical(_loginAcceptance, pending)) _loginAcceptance = null;
      }));
    } catch (e) {
      log('legal: sign-in agreement not started: $e');
    }
  }

  /// GET customer/legal/status. Null when logged out or on any failure
  /// (silent). Also refreshes the known versions from the reply.
  Future<LegalStatus?> checkStatus() async {
    if (!_isLoggedIn()) return null;
    try {
      final status = LegalStatus.fromJson(await _api.fetchStatus());
      if (status == null) return null;
      _lastStatus = status;
      if (documents.isNotEmpty) {
        final fromStatus = status.asDocuments(documents);
        if (fromStatus.isNotEmpty) await _store(mergeLegalDocuments(documents, fromStatus));
      }
      return status;
    } catch (e) {
      log('legal: status check failed: $e');
      return null;
    }
  }

  // ── "We've updated our terms" prompt ─────────────────────────────────

  bool get _promptedThisSession => _prompted && _promptedUser == _currentUserId();

  /// For the dashboard: the status to prompt with, or null when there's
  /// nothing to show (logged out, already shown this app run for this user,
  /// nothing new, or the check failed). Returning a status marks the prompt
  /// as shown, so it appears at most once per app run.
  Future<LegalStatus?> statusForPrompt({Duration waitForSignIn = const Duration(seconds: 15)}) async {
    if (_promptChecking || !_isLoggedIn() || _promptedThisSession) return null;
    _promptChecking = true;
    try {
      // A new sign-in is still recording its agreement — let it land first,
      // so the user isn't asked about terms they agreed to seconds ago.
      final signIn = _loginAcceptance;
      if (signIn != null) await signIn.timeout(waitForSignIn, onTimeout: () {});
      final status = await checkStatus();
      if (!shouldShowLegalPrompt(
        loggedIn: _isLoggedIn(),
        status: status,
        alreadyShownThisSession: _promptedThisSession,
      )) {
        return null;
      }
      _prompted = true;
      _promptedUser = _currentUserId();
      return status;
    } finally {
      _promptChecking = false;
    }
  }
}

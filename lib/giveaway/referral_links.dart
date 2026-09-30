import 'dart:async';
import 'dart:io' show Platform;

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../share/trek_link.dart';
import '../utils/shared_preferences.dart';
import 'giveaway_config.dart';

/// Pure parsing for referral codes arriving from outside the app. Everything
/// here is untrusted input: only a well-formed code is ever kept.
class ReferralLinkParser {
  ReferralLinkParser._();

  /// Same rule as the OTP screen's referral field (4–16 letters or digits).
  /// Today's codes are "AORBO" + 5 (services/referralService.js); the wider
  /// rule keeps older or future formats from being silently dropped — the
  /// backend is what decides whether a code is real.
  static final RegExp codePattern = RegExp(r'^[A-Z0-9]{4,16}$');

  static String? normalize(String? raw) {
    final code = raw?.trim().toUpperCase();
    if (code == null || !codePattern.hasMatch(code)) return null;
    return code;
  }

  /// `https://<referral host>/r/<CODE>` → CODE. Anything else → null.
  static String? fromUri(Uri uri) {
    if (uri.scheme != 'https') return null;
    if (!GiveawayConfig.referralLinkHosts.contains(uri.host.toLowerCase())) return null;
    if (uri.hasPort && uri.port != 443) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length != 2 || segments[0] != 'r') return null;
    return normalize(segments[1]);
  }

  /// Play install referrer string ("ref=CODE&utm_source=…") → CODE. Only the
  /// `ref` value is read; everything else in it is ignored.
  static String? fromInstallReferrer(String? referrer) {
    if (referrer == null || referrer.isEmpty || referrer.length > 1024) return null;
    try {
      return normalize(Uri.splitQueryString(referrer)['ref']);
    } catch (_) {
      return null;
    }
  }
}

/// Holds the referral code from a friend's link until the sign-up screen
/// uses it. The code is only ever pre-filled — the person still sees it and
/// the backend decides at verify-otp whether it applies (new accounts only).
class PendingReferralCode {
  PendingReferralCode._();

  static const String _codeKey = 'giveaway_pending_referral_code';
  static const String _savedAtKey = 'giveaway_pending_referral_saved_at';
  static const Duration maxAge = Duration(days: 30);

  static Future<void> save(String code) async {
    final sp = await SpUtil.getInstance();
    await sp.putString(_codeKey, code);
    await sp.putInt(_savedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// The saved code, or null when there is none or it is older than [maxAge].
  static Future<String?> read() async {
    final sp = await SpUtil.getInstance();
    final code = ReferralLinkParser.normalize(sp.getString(_codeKey));
    final savedAt = sp.getInt(_savedAtKey);
    if (code == null || savedAt == null) return null;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(savedAt));
    if (age.isNegative || age > maxAge) {
      await clear();
      return null;
    }
    return code;
  }

  static Future<void> clear() async {
    final sp = await SpUtil.getInstance();
    await sp.remove(_codeKey);
    await sp.remove(_savedAtKey);
  }
}

/// Listens for Aorbo links (App Links) and reads the Play install referrer
/// once per install. Referral links: a captured code is saved for the sign-up
/// screen; a signed-in user is taken to the giveaway page instead. Trek links
/// (lib/share/trek_link.dart): opened once the person is signed in.
class ReferralLinkCapture {
  ReferralLinkCapture._();
  static final ReferralLinkCapture instance = ReferralLinkCapture._();

  static const String _referrerCheckedKey = 'giveaway_install_referrer_checked';

  StreamSubscription<Uri>? _sub;
  bool _started = false;

  /// Set when a link opened the app while signed in; the dashboard opens the
  /// giveaway once it is on screen, then clears this.
  final RxBool openGiveawayRequested = false.obs;

  /// Set when a trek link arrives while signed in; the dashboard opens the
  /// trek, then clears this. Signed out, the link waits in [PendingTrekLink].
  final Rxn<TrekLink> openTrekRequested = Rxn<TrekLink>();

  /// [isLoggedIn] is read at the moment a link arrives.
  Future<void> start({required bool Function() isLoggedIn}) async {
    if (_started || kIsWeb) return;
    _started = true;

    unawaited(_readInstallReferrerOnce());

    final links = AppLinks();
    try {
      final initial = await links.getInitialLink();
      if (initial != null) await _handle(initial, isLoggedIn());
    } catch (e) {
      debugPrint('ReferralLinkCapture: initial link unavailable: $e');
    }
    _sub = links.uriLinkStream.listen(
      (uri) => _handle(uri, isLoggedIn()),
      onError: (Object e) => debugPrint('ReferralLinkCapture: link stream error: $e'),
    );
  }

  Future<void> _handle(Uri uri, bool loggedIn) async {
    final trek = TrekLink.fromUri(uri);
    if (trek != null) {
      if (loggedIn) {
        openTrekRequested.value = trek;
      } else {
        await PendingTrekLink.save(trek);
      }
      return;
    }
    final code = ReferralLinkParser.fromUri(uri);
    if (code == null) return;
    if (loggedIn) {
      // A code only applies to a new account; for a signed-in user the link
      // just leads to the campaign (the "invite friends" view for them).
      if (GiveawayConfig.enabled) openGiveawayRequested.value = true;
      return;
    }
    await PendingReferralCode.save(code);
  }

  Future<void> _readInstallReferrerOnce() async {
    if (!Platform.isAndroid) return;
    try {
      final sp = await SpUtil.getInstance();
      if (sp.getBool(_referrerCheckedKey) == true) return;
      final details = await AndroidPlayInstallReferrer.installReferrer;
      await sp.putBool(_referrerCheckedKey, true);
      final code = ReferralLinkParser.fromInstallReferrer(details.installReferrer);
      // An App Link code, if any, is more recent — don't overwrite it.
      if (code != null && await PendingReferralCode.read() == null) {
        await PendingReferralCode.save(code);
      }
      final trek = TrekLink.fromInstallReferrer(details.installReferrer);
      if (trek != null && await PendingTrekLink.read() == null) {
        await PendingTrekLink.save(trek);
      }
    } catch (e) {
      // Sideloaded builds and phones without Play have no referrer — normal.
      debugPrint('ReferralLinkCapture: install referrer unavailable: $e');
    }
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }
}

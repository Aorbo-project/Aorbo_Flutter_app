import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Remote kill switches for the app's security layers, via Firebase Remote
/// Config (Firebase console → Remote Config).
///
/// Fetched from Google's servers — NOT our API — so they keep working even
/// if our own TLS pinning is what's broken. Defaults are "protection on";
/// the last fetched values persist across launches.
///
///   api_tls_pinning_enabled  false = trust the normal system CA store for
///                            the API (use when Cloudflare moves our edge
///                            certificate to a CA the app doesn't pin yet)
///   rasp_block_enabled       false = never show the "device not secure"
///                            block screen (detection + reporting continue)
class SecurityConfig {
  SecurityConfig._();

  static const String _pinningKey = 'api_tls_pinning_enabled';
  static const String _raspBlockKey = 'rasp_block_enabled';

  static bool _pinningEnabled = true;
  static bool _raspBlockEnabled = true;

  static bool get pinningEnabled => _pinningEnabled;
  static bool get raspBlockEnabled => _raspBlockEnabled;

  /// Apply the last-activated values — local and fast, no network. Call
  /// before the first API request so the HTTP client is built with them.
  static Future<void> loadCached() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setDefaults(const {_pinningKey: true, _raspBlockKey: true});
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 30),
      ));
      _read(rc);
    } catch (e) {
      debugPrint('SecurityConfig: cached remote config unavailable, keeping defaults: $e');
    }
  }

  /// Fetch fresh values from Google. Returns true if anything changed.
  static Future<bool> refresh() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      final before = (_pinningEnabled, _raspBlockEnabled);
      await rc.fetchAndActivate();
      _read(rc);
      return before != (_pinningEnabled, _raspBlockEnabled);
    } catch (e) {
      debugPrint('SecurityConfig: remote config fetch failed, keeping current values: $e');
      return false;
    }
  }

  static void _read(FirebaseRemoteConfig rc) {
    _pinningEnabled = rc.getBool(_pinningKey);
    _raspBlockEnabled = rc.getBool(_raspBlockKey);
  }

  @visibleForTesting
  static void overrideForTest({bool? pinning, bool? raspBlock}) {
    if (pinning != null) _pinningEnabled = pinning;
    if (raspBlock != null) _raspBlockEnabled = raspBlock;
  }
}

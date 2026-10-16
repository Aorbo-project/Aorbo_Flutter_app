import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A random code for this installation of the app (16 Oct 2026), sent as
/// `X-App-Install` so the server can count how many phones use each build and
/// how many get past the opening screen (backend services/appHealth). Random —
/// not derived from the phone, the account or any hardware id — and it changes
/// when the app is reinstalled. The server stores only a one-way daily hash.
class InstallId {
  InstallId._();

  static const String header = 'X-App-Install';
  static const String _key = 'aorbo_install_id';

  static String? _current;

  /// The code, or null before [load] (or if storage failed).
  static String? get current => _current;

  @visibleForTesting
  static set current(String? v) => _current = v;

  /// 24 lowercase hex characters from a secure random source.
  @visibleForTesting
  static String generate([Random? random]) {
    final r = random ?? Random.secure();
    return List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  static bool isValid(String? v) => v != null && RegExp(r'^[0-9a-f]{24}$').hasMatch(v);

  /// Reads the stored code or creates one. Never throws.
  static Future<String?> load({Future<SharedPreferences> Function()? prefs}) async {
    if (_current != null) return _current;
    try {
      final p = await (prefs ?? SharedPreferences.getInstance)();
      var id = p.getString(_key);
      if (!isValid(id)) {
        id = generate();
        await p.setString(_key, id);
      }
      _current = id;
    } catch (e) {
      debugPrint('InstallId.load failed: $e');
    }
    return _current;
  }
}

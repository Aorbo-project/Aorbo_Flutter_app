import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android FLAG_SECURE for the screens that show a one-time code or take a
/// payment (scan E10, owner's choice: the OTP step and payment only).
/// While on, the screen is blank in the recent-apps thumbnail, screenshots
/// and screen recording / sharing (a "support" scammer watching the
/// customer's screen cannot read the OTP). Tickets stay shareable.
///
/// Reference-counted so nested screens can't switch it off early. Never
/// throws: on iOS / tests without the native side it simply does nothing.
class ScreenSecurity {
  ScreenSecurity._();

  static const MethodChannel channel =
      MethodChannel('com.aorbotreks.app/screen_security');

  static int _holders = 0;

  /// Whether FLAG_SECURE is currently requested.
  static bool get isSecure => _holders > 0;

  static Future<void> enter() async {
    _holders++;
    if (_holders == 1) await _set(true);
  }

  static Future<void> leave() async {
    if (_holders == 0) return;
    _holders--;
    if (_holders == 0) await _set(false);
  }

  static Future<void> _set(bool secure) async {
    try {
      await channel.invokeMethod<bool>('setSecure', {'secure': secure});
    } catch (e) {
      if (kDebugMode) debugPrint('ScreenSecurity: $e');
    }
  }

  @visibleForTesting
  static void resetForTest() => _holders = 0;
}

/// Holds [ScreenSecurity] while a condition is true (e.g. "the OTP step is
/// showing"); [sync] is cheap and idempotent, [release] on dispose.
class ScreenSecurityHold {
  bool _held = false;

  bool get isHeld => _held;

  void sync(bool wanted) {
    if (wanted == _held) return;
    _held = wanted;
    wanted ? ScreenSecurity.enter() : ScreenSecurity.leave();
  }

  void release() => sync(false);
}

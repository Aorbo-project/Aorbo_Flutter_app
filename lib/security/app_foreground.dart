import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Brings the app back in front of a UPI app (PhonePe, GPay, ...) that a
/// payment left behind.
///
/// Razorpay opens the UPI app INSIDE our Android task. When the payment is
/// settled without the UPI app finishing, its window can stay on top of our
/// screens. Seen 2026-10-12 on a vivo phone (adb logs + screen recording):
/// PhonePe said "Something went wrong", then stayed as an invisible window
/// over the booking screen. The customer saw the booking, but every tap went
/// to PhonePe, so the app looked frozen until they swiped back or killed it.
///
/// Once the SERVER says the order is paid (or refunded), nothing the UPI app
/// does can change the outcome. So the app asks Android to bring its own
/// screen back and close whatever sits above it in its task
/// (FLAG_ACTIVITY_CLEAR_TOP, see MainActivity.kt). Android may refuse while
/// the app is not visible (for example while the screen is off), so it asks
/// again every [retryEvery] until the app is in front, for at most
/// [giveUpAfter]. When the app is already in front it does nothing. Never
/// throws: on iOS / in tests there is no native side.
class AppForeground {
  AppForeground._();

  static const MethodChannel channel =
      MethodChannel('com.aorbotreks.app/app_task');

  static const Duration retryEvery = Duration(seconds: 2);
  static const Duration giveUpAfter = Duration(seconds: 60);

  static Timer? _retry;

  /// An unknown state (null: before the first frame, or in tests) counts as
  /// "in front" — never pull the app forward on a guess.
  static bool get _inFront {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  /// Call once the server has settled the order (paid / refunded).
  static void reclaimAfterPayment() {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    _stop();
    if (_inFront) return;
    _ask();
    final maxTries = giveUpAfter.inMilliseconds ~/ retryEvery.inMilliseconds;
    var tries = 0;
    _retry = Timer.periodic(retryEvery, (timer) {
      tries++;
      if (_inFront || tries > maxTries) {
        _stop();
        return;
      }
      _ask();
    });
  }

  static void _stop() {
    _retry?.cancel();
    _retry = null;
  }

  static Future<void> _ask() async {
    try {
      await channel.invokeMethod<bool>('reclaimForeground');
    } catch (e) {
      if (kDebugMode) debugPrint('AppForeground: $e');
    }
  }

  @visibleForTesting
  static bool get isRetrying => _retry != null;

  @visibleForTesting
  static void resetForTest() => _stop();
}

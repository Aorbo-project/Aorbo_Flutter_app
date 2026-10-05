import 'dart:async';

import 'package:arobo_app/controller/coupon_controller.dart';
import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/controller/notification_controller.dart';
import 'package:arobo_app/controller/referral_controller.dart';
import 'package:arobo_app/controller/ticket_controller.dart';
import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/controller/user_controller.dart';
import 'package:arobo_app/main.dart' show sp;
import 'package:arobo_app/repository/repository.dart';
import 'package:arobo_app/security/device_key_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Ends the signed-in person's session on this phone. The one path for the
/// Logout button, the server signing the user out (401 / 403
/// ACCOUNT_INACTIVE) and the next sign-in (scan E2 / E3).
class SessionTeardown {
  SessionTeardown._();

  /// Stored values that belong to the phone, not to the person: a trek or
  /// referral link tapped before signing in (still opened after sign-in),
  /// and the one-time Play install-referrer check (reading it again would
  /// offer the same referral code to the next account).
  static const Set<String> keptPrefKeys = {
    'pending_trek_link_code',
    'pending_trek_link_saved_at',
    'giveaway_pending_referral_code',
    'giveaway_pending_referral_saved_at',
    'giveaway_install_referrer_checked',
  };

  /// Replaceable in tests.
  @visibleForTesting
  static Future<void> Function() deleteFcmToken =
      () => FirebaseMessaging.instance.deleteToken();

  /// Clears the stored session (tokens, profile flags, pending order, the
  /// FCM-synced marker ...) except [keptPrefKeys], forgets the access token,
  /// and — best effort, bounded, never throwing — clears the crash-report
  /// user id, drops the device key and deletes this phone's FCM token so the
  /// previous customer's booking / refund pushes stop arriving (E3).
  static Future<void> clearLocalSession() async {
    Repository.token = '';
    final prefs = sp;
    if (prefs != null) {
      final kept = <String, Object>{};
      for (final key in keptPrefKeys) {
        final value = prefs.get(key);
        if (value != null) kept[key] = value as Object;
      }
      await prefs.clear();
      for (final entry in kept.entries) {
        final v = entry.value;
        if (v is String) {
          await prefs.putString(entry.key, v);
        } else if (v is bool) {
          await prefs.putBool(entry.key, v);
        } else if (v is int) {
          await prefs.putInt(entry.key, v);
        }
      }
    }
    await _quietly(() => FirebaseCrashlytics.instance.setUserIdentifier(''));
    await _quietly(DeviceKeyService.instance.reset);
    await _quietly(deleteFcmToken);
  }

  /// Removes the controllers that hold one person's data (bookings, failed
  /// payments, profile, coupons, notifications ...). They are registered
  /// `permanent`, so after a forced sign-out the next person's dashboard would
  /// otherwise get the SAME instances back — with the previous customer's
  /// bookings still "fresh" in memory (E2). Called on a successful sign-in,
  /// before the dashboard mounts; the login controllers are left alone.
  static void dropUserControllers() {
    void drop<T>() {
      if (Get.isRegistered<T>()) Get.delete<T>(force: true);
    }

    drop<DashboardController>();
    drop<TrekController>();
    drop<CouponController>();
    drop<UserController>();
    drop<NotificationController>();
    drop<ReferralController>();
    drop<TicketController>();
  }

  static Future<void> _quietly(Future<void> Function() step) async {
    try {
      await step().timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) debugPrint('SessionTeardown: $e');
    }
  }
}

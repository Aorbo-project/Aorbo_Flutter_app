import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Where a notification tap leads.
@immutable
class PushTarget {
  const PushTarget(this.route, {this.bookingId});

  /// A registered GetX route name.
  final String route;

  /// The booking the notification is about, when it names one.
  final int? bookingId;

  Map<String, dynamic>? get arguments =>
      bookingId == null ? null : {'booking_id': bookingId};

  @override
  bool operator ==(Object other) =>
      other is PushTarget && other.route == route && other.bookingId == bookingId;

  @override
  int get hashCode => Object.hash(route, bookingId);

  @override
  String toString() => 'PushTarget($route, bookingId: $bookingId)';
}

int? _intOf(Object? v) => v is int ? v : int.tryParse('${v ?? ''}');

/// The one mapping from a push's `data` to a screen (scan E1 / E11), used for
/// every way a tap arrives: the app was closed (getInitialMessage), in the
/// background (onMessageOpenedApp), or open (the re-posted local
/// notification's payload), and by the in-app notification list.
/// Null = nothing specific to open.
PushTarget? routeForPush(
  Map<String, dynamic> data, {
  required bool giveawayEnabled,
}) {
  final bookingId = _intOf(
    data['bookingId'] ?? data['booking_id'] ?? data['id'],
  );
  switch (data['event']?.toString()) {
    case 'BOOKING_CONFIRMED':
    case 'TREK_REMINDER':
    case 'TREK_DEPARTURE_SOON':
    case 'TREK_CANCELLED_BY_VENDOR':
    case 'BOOKING_PAYMENT_FAILED':
    case 'REFUND_INITIATED':
    case 'REFUND_COMPLETED':
    case 'REFUND_ISSUED':
    case 'SLOT_SOLD_OUT_REFUND':
      return PushTarget('/my-bookings', bookingId: bookingId);
    case 'COUPON_EXPIRING':
      return const PushTarget('/coupon-code');
    // Aorbo Trek Giveaway: draw reminders + "the result is out".
    case 'GIVEAWAY_REMINDER':
    case 'GIVEAWAY_RESULTS':
      return giveawayEnabled ? const PushTarget('/giveaway') : null;
  }
  if (data['type']?.toString() == 'booking') {
    final id = _intOf(data['booking_id'] ?? data['id']);
    if (id != null) return PushTarget('/my-bookings', bookingId: id);
  }
  return null;
}

/// The local-notification payload for a re-posted foreground push.
String encodePushPayload(Map<String, dynamic> data) => jsonEncode(data);

/// The push data back from a local-notification payload (null if unusable).
Map<String, dynamic>? decodePushPayload(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  try {
    final decoded = jsonDecode(payload);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
  } catch (_) {
    return null;
  }
}

/// A notification tap waiting for the signed-in dashboard to open it.
///
/// Taps arrive before any screen can act on them (a cold start goes through
/// the splash and the session check first), so they are parked here and
/// [DashboardMain] opens them after its first frame or as they come in.
class PendingPush {
  PendingPush._();

  static final PendingPush instance = PendingPush._();

  /// The last tap's data; null when nothing is waiting.
  final Rxn<Map<String, dynamic>> tapped = Rxn<Map<String, dynamic>>();

  /// Parks a tap. A tap while signed out is dropped: whoever signs in next
  /// may not be the person the notification was for.
  void save(Map<String, dynamic> data, {required bool signedIn}) {
    if (!signedIn || data.isEmpty) return;
    tapped.value = Map<String, dynamic>.from(data);
  }

  /// The waiting tap, removed.
  Map<String, dynamic>? take() {
    final data = tapped.value;
    tapped.value = null;
    return data;
  }
}

/// Listens for FCM notification taps and parks them in [PendingPush].
class PushTapCapture {
  PushTapCapture._();

  static StreamSubscription<RemoteMessage>? _opened;

  /// Scan E1: the tap that STARTED the app (it was closed — the usual case)
  /// only comes from getInitialMessage(); taps while it is in the background
  /// come from onMessageOpenedApp. Call once, as early as possible.
  static void start({required bool Function() signedIn}) {
    try {
      _opened ??= FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => PendingPush.instance.save(m.data, signedIn: signedIn()),
      );
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((m) {
            if (m != null) {
              PendingPush.instance.save(m.data, signedIn: signedIn());
            }
          })
          .catchError((Object e) {
            if (kDebugMode) debugPrint('getInitialMessage failed: $e');
          });
    } catch (e) {
      if (kDebugMode) debugPrint('Push tap listeners failed: $e');
    }
  }

  @visibleForTesting
  static Future<void> stopForTest() async {
    await _opened?.cancel();
    _opened = null;
  }
}

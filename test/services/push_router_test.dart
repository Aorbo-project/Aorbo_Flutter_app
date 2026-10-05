// Scan E1: a notification tap must open its screen however it arrives —
// with the app closed (getInitialMessage), in the background
// (onMessageOpenedApp) or open (the re-posted local notification's payload).

import 'package:arobo_app/services/push_router.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../firebase_test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('routeForPush', () {
    PushTarget? route(Map<String, dynamic> d, {bool giveaway = true}) =>
        routeForPush(d, giveawayEnabled: giveaway);

    test('booking and refund events open My Bookings with the booking id', () {
      for (final event in [
        'BOOKING_CONFIRMED',
        'TREK_REMINDER',
        'TREK_DEPARTURE_SOON',
        'TREK_CANCELLED_BY_VENDOR',
        'BOOKING_PAYMENT_FAILED',
        'REFUND_INITIATED',
        'REFUND_COMPLETED',
        'REFUND_ISSUED',
        'SLOT_SOLD_OUT_REFUND',
      ]) {
        expect(route({'event': event, 'bookingId': '123'}), const PushTarget('/my-bookings', bookingId: 123), reason: event);
      }
      expect(route({'event': 'REFUND_ISSUED', 'booking_id': 9}), const PushTarget('/my-bookings', bookingId: 9));
      expect(route({'event': 'BOOKING_CONFIRMED', 'id': '7'}), const PushTarget('/my-bookings', bookingId: 7));
      expect(route({'event': 'BOOKING_CONFIRMED'}), const PushTarget('/my-bookings'));
    });

    test('coupon and giveaway events', () {
      expect(route({'event': 'COUPON_EXPIRING'}), const PushTarget('/coupon-code'));
      expect(route({'event': 'GIVEAWAY_REMINDER'}), const PushTarget('/giveaway'));
      expect(route({'event': 'GIVEAWAY_RESULTS'}), const PushTarget('/giveaway'));
      expect(route({'event': 'GIVEAWAY_RESULTS'}, giveaway: false), isNull);
    });

    test('legacy type=booking payloads; unknown pushes open nothing', () {
      expect(route({'type': 'booking', 'id': '55'}), const PushTarget('/my-bookings', bookingId: 55));
      expect(route({'type': 'booking'}), isNull);
      expect(route({'event': 'SOMETHING_NEW'}), isNull);
      expect(route({}), isNull);
    });

    test('arguments carry the booking id only when known', () {
      expect(const PushTarget('/my-bookings', bookingId: 5).arguments, {'booking_id': 5});
      expect(const PushTarget('/coupon-code').arguments, isNull);
    });
  });

  test('a re-posted foreground push carries its data as the payload (round trip)', () {
    final data = {'event': 'REFUND_ISSUED', 'bookingId': '42'};
    expect(decodePushPayload(encodePushPayload(data)), data);
    expect(decodePushPayload(null), isNull);
    expect(decodePushPayload('not json'), isNull);
    expect(decodePushPayload('[1,2]'), isNull);
  });

  group('PendingPush', () {
    tearDown(() => PendingPush.instance.take());

    test('a tap while signed in waits until taken, once', () {
      PendingPush.instance.save({'event': 'BOOKING_CONFIRMED', 'bookingId': '1'}, signedIn: true);
      expect(PendingPush.instance.take(), {'event': 'BOOKING_CONFIRMED', 'bookingId': '1'});
      expect(PendingPush.instance.take(), isNull);
    });

    test('a tap while signed out is dropped (the next person may be someone else)', () {
      PendingPush.instance.save({'event': 'BOOKING_CONFIRMED', 'bookingId': '1'}, signedIn: false);
      expect(PendingPush.instance.tapped.value, isNull);
    });
  });

  group('PushTapCapture', () {
    late FakeMessagingPlatform messaging;

    setUp(() async {
      await setUpFakeFirebase();
      messaging = setUpFakeMessaging();
    });

    tearDown(() async {
      await PushTapCapture.stopForTest();
      PendingPush.instance.take();
    });

    test('the tap that started a closed app (getInitialMessage) is parked', () async {
      messaging.initialMessage = const RemoteMessage(data: {'event': 'GIVEAWAY_RESULTS'});
      PushTapCapture.start(signedIn: () => true);
      await Future<void>.delayed(Duration.zero);
      expect(PendingPush.instance.take(), {'event': 'GIVEAWAY_RESULTS'});
    });

    test('a tap while the app is in the background (onMessageOpenedApp) is parked', () async {
      PushTapCapture.start(signedIn: () => true);
      FirebaseMessagingPlatform.onMessageOpenedApp.add(
        const RemoteMessage(data: {'event': 'REFUND_COMPLETED', 'bookingId': '8'}),
      );
      await Future<void>.delayed(Duration.zero);
      expect(PendingPush.instance.take(), {'event': 'REFUND_COMPLETED', 'bookingId': '8'});
    });
  });
}

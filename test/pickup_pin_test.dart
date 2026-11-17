// Pickup pin (owner, 17 Nov 2026): Google Maps links, pins only when real, model fields.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/widgets/pickup_pin.dart';
import 'package:arobo_app/freezed_models/json_converters.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart';

void main() {
  test('Google Maps links: the place on the trek page, directions on the ticket', () {
    expect(pickupMapsUri(17.3781414, 78.485106).toString(),
        'https://www.google.com/maps/search/?api=1&query=17.3781414%2C78.4851060');
    expect(pickupMapsUri(17.3781414, 78.485106, directions: true).toString(),
        'https://www.google.com/maps/dir/?api=1&destination=17.3781414%2C78.4851060');
  });

  test('a pin only when it is real', () {
    expect(hasPickupPin(17.37, 78.48), isTrue);
    expect(hasPickupPin(null, 78.48), isFalse);
    expect(hasPickupPin(0, 0), isFalse);
    expect(hasPickupPin(95, 10), isFalse);
    expect(jsonToCoordinate('17.37814140'), closeTo(17.3781414, 1e-9));
    expect(jsonToCoordinate(''), isNull);
    expect(jsonToCoordinate('abc'), isNull);
    expect(jsonToCoordinate(200), isNull);
  });

  test('trek page stop: label + pin from the server; an older stop has none', () {
    final s = TrekStages.fromJson({
      'stage_name': 'boarding', 'destination': 'Mahatma Gandhi Bus Station', 'is_boarding_point': true,
      'place_label': 'Bus stand', 'latitude': '17.37814140', 'longitude': 78.485106,
    });
    expect(s.placeLabel, 'Bus stand');
    expect(s.latitude, closeTo(17.3781414, 1e-9));
    final old = TrekStages.fromJson({'stage_name': 'boarding', 'destination': 'Majestic'});
    expect(old.placeLabel, isNull);
    expect(hasPickupPin(old.latitude, old.longitude), isFalse);
  });

  test('booking: pin, kind and meeting spot; an older booking has none', () {
    final t = Trek.fromJson({
      'boarding_point': 'Mahatma Gandhi Bus Station', 'boarding_lat': 17.3781414, 'boarding_lon': '78.485106',
      'boarding_kind': 'Bus stand', 'boarding_note': 'Platform 1 exit',
    });
    expect(t.boardingKind, 'Bus stand');
    expect(t.boardingNote, 'Platform 1 exit');
    expect(hasPickupPin(t.boardingLat, t.boardingLon), isTrue);
    final old = Trek.fromJson({'boarding_point': 'Majestic'});
    expect(hasPickupPin(old.boardingLat, old.boardingLon), isFalse);
  });

  testWidgets('the pin is a small tappable circle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: PickupPinButton(lat: 17.37, lon: 78.48)))));
    expect(find.byKey(const ValueKey('pickup-pin')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('pickup-pin'))), const Size(28, 28));
    expect(find.bySemanticsLabel('Show the pickup on the map'), findsOneWidget);
  });
}

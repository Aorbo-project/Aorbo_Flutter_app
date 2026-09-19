// Coverage for FeaturedDestinationDetail.fromJson / RelatedTrek.fromJson —
// the model that parses aorbotreks.com's `GET /api/treks/<id>/` response
// (a separate, less-controlled backend from our own) onto the native
// Featured Destination detail screen. These tests exist because that API's
// JSON is defensively decoded field-by-field (missing keys, wrong types,
// "N/A" sentinels) rather than trusted to always match the documented
// shape, and every one of those fallbacks needs to be proven, not assumed.

import 'package:flutter_test/flutter_test.dart';
import 'package:arobo_app/models/featured_destination_detail.dart';

void main() {
  group('FeaturedDestinationDetail.fromJson — happy path', () {
    test('parses a fully-populated response', () {
      final detail = FeaturedDestinationDetail.fromJson({
        'id': 42,
        'name': 'Kedarkantha Trek',
        'description': 'Beautiful snow trek.',
        'state': 'Himachal Pradesh',
        'price_start': 15000,
        'duration_days': '3D/2N,4D/3N,5D/4N',
        'operating_days': 'THU, FRI, SAT',
        'main_image': 'https://example.com/img.jpg',
        'activities': ['Trekking', 'Photography'],
        'famous_places': ['Kedarnath Temple', 'Base Camp'],
        'operators': ['Smart Travel Hub'],
        'related_treks': [
          {'id': 7, 'slug': 7, 'name': 'Chopta Trek', 'state': 'Uttarakhand'},
        ],
        'latitude': 30.751111,
        'longitude': 78.850556,
      });

      expect(detail.id, 42);
      expect(detail.name, 'Kedarkantha Trek');
      expect(detail.description, 'Beautiful snow trek.');
      expect(detail.state, 'Himachal Pradesh');
      expect(detail.priceStart, '15000');
      expect(detail.durationDays, '3D/2N,4D/3N,5D/4N');
      expect(detail.operatingDays, 'THU, FRI, SAT');
      expect(detail.mainImage, 'https://example.com/img.jpg');
      expect(detail.activities, ['Trekking', 'Photography']);
      expect(detail.famousPlaces, ['Kedarnath Temple', 'Base Camp']);
      expect(detail.operators, ['Smart Travel Hub']);
      expect(detail.relatedTreks, hasLength(1));
      expect(detail.relatedTreks.first.id, 7);
      expect(detail.relatedTreks.first.name, 'Chopta Trek');
      expect(detail.relatedTreks.first.state, 'Uttarakhand');
      expect(detail.latitude, 30.751111);
      expect(detail.longitude, 78.850556);
    });
  });

  group('FeaturedDestinationDetail.fromJson — missing/absent fields', () {
    test('an almost-empty map falls back to safe defaults, never throws', () {
      final detail = FeaturedDestinationDetail.fromJson({});

      expect(detail.id, isNull);
      expect(detail.name, '');
      expect(detail.description, '');
      expect(detail.state, '');
      expect(detail.priceStart, isNull);
      expect(detail.durationDays, '3D/2N');
      expect(detail.operatingDays, 'Thu, Fri, Sat');
      expect(detail.mainImage, '');
      expect(detail.activities, isEmpty);
      expect(detail.famousPlaces, isEmpty);
      expect(detail.operators, isEmpty);
      expect(detail.relatedTreks, isEmpty);
      expect(detail.latitude, isNull);
      expect(detail.longitude, isNull);
    });

    test('id as a non-int (e.g. a string slug) becomes null, not a cast error', () {
      final detail = FeaturedDestinationDetail.fromJson({'id': 'kedarkantha-trek'});
      expect(detail.id, isNull);
    });
  });

  group('FeaturedDestinationDetail.fromJson — price_start edge cases', () {
    test('a numeric price is stringified', () {
      final detail = FeaturedDestinationDetail.fromJson({'price_start': 15000});
      expect(detail.priceStart, '15000');
    });

    test('the "N/A" sentinel from the list endpoint style becomes null', () {
      final detail = FeaturedDestinationDetail.fromJson({'price_start': 'N/A'});
      expect(detail.priceStart, isNull);
    });

    test('null price_start stays null', () {
      final detail = FeaturedDestinationDetail.fromJson({'price_start': null});
      expect(detail.priceStart, isNull);
    });
  });

  group('FeaturedDestinationDetail.fromJson — list fields with bad shapes', () {
    test('a non-list value for activities/famous_places/operators becomes an empty list', () {
      final detail = FeaturedDestinationDetail.fromJson({
        'activities': 'not a list',
        'famous_places': 42,
        'operators': null,
      });
      expect(detail.activities, isEmpty);
      expect(detail.famousPlaces, isEmpty);
      expect(detail.operators, isEmpty);
    });

    test('blank/empty strings inside a list are dropped, not kept as blanks', () {
      final detail = FeaturedDestinationDetail.fromJson({
        'activities': ['Trekking', '', '  '.trim(), 'Photography'],
      });
      expect(detail.activities, ['Trekking', 'Photography']);
    });

    test('related_treks entries that are not maps are skipped, not crashed on', () {
      final detail = FeaturedDestinationDetail.fromJson({
        'related_treks': [
          {'id': 1, 'name': 'Valid Trek', 'state': 'Karnataka'},
          'not a map',
          42,
        ],
      });
      expect(detail.relatedTreks, hasLength(1));
      expect(detail.relatedTreks.first.name, 'Valid Trek');
    });

    test('related_treks itself being the wrong type (not a List) becomes empty', () {
      final detail = FeaturedDestinationDetail.fromJson({'related_treks': 'oops'});
      expect(detail.relatedTreks, isEmpty);
    });
  });

  group('FeaturedDestinationDetail.fromJson — latitude/longitude number types', () {
    test('an int latitude/longitude (not double) still converts cleanly', () {
      final detail = FeaturedDestinationDetail.fromJson({'latitude': 30, 'longitude': 78});
      expect(detail.latitude, 30.0);
      expect(detail.longitude, 78.0);
    });

    test('a non-numeric latitude/longitude becomes null rather than throwing', () {
      final detail = FeaturedDestinationDetail.fromJson({'latitude': 'oops', 'longitude': true});
      expect(detail.latitude, isNull);
      expect(detail.longitude, isNull);
    });
  });

  group('RelatedTrek.fromJson', () {
    test('missing fields fall back to safe defaults', () {
      final trek = RelatedTrek.fromJson({});
      expect(trek.id, isNull);
      expect(trek.name, '');
      expect(trek.state, '');
    });

    test('a string id becomes null instead of throwing', () {
      final trek = RelatedTrek.fromJson({'id': 'not-an-int'});
      expect(trek.id, isNull);
    });
  });
}

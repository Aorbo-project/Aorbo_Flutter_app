// Scan E0-4 / E0-7: loosely-typed backend fields (mostly vendor-entered JSON
// columns) must parse instead of throwing a TypeError that blanks the whole
// trek-detail / bookings / profile screen.

import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:arobo_app/freezed_models/booking/booking_history_model.dart'
    as history;
import 'package:arobo_app/freezed_models/json_converters.dart';
import 'package:arobo_app/freezed_models/profile/user_profile_model.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

TrekDetailData _trek(Map<String, dynamic> fields) =>
    TrekDetailData.fromJson({'id': 1, 'title': 'Kedarkantha', ...fields});

void main() {
  group('E0-4 LatestReviews.rating_value', () {
    int? rating(Object? v) =>
        LatestReviews.fromJson({'rating_value': v}).ratingValue;

    test('4, 4.0, 4.5 and "4" all parse to whole stars', () {
      expect(rating(4), 4);
      expect(rating(4.0), 4);
      expect(rating(4.5), 5); // rounded
      expect(rating('4'), 4);
      expect(rating('4.0'), 4);
      expect(rating(null), isNull);
      expect(rating('n/a'), isNull);
    });

    test('a trek with mixed rating types still parses and sorts', () {
      final trek = _trek({
        'latest_reviews': [
          {'customer_name': 'A', 'rating_value': 3},
          {'customer_name': 'B', 'rating_value': 4.5},
          {'customer_name': 'C', 'rating_value': '4'},
        ],
      });
      final list = [...trek.latestReviews!]
        ..sort((a, b) => (b.ratingValue ?? 0).compareTo(a.ratingValue ?? 0));
      expect(list.map((r) => r.customerName), ['B', 'C', 'A']);
      expect('Rated ${list.first.ratingValue} stars', 'Rated 5 stars');
    });
  });

  group('E0-7 trek detail vendor-entered fields', () {
    test('city_ids: numbers, numeric strings, JSON string, comma list, junk', () {
      expect(_trek({'city_ids': [1, '2', 3.0]}).cityIds, [1, 2, 3]);
      expect(_trek({'city_ids': '[4,5]'}).cityIds, [4, 5]);
      expect(_trek({'city_ids': '6, 7'}).cityIds, [6, 7]);
      expect(_trek({'city_ids': [8, 'x', null]}).cityIds, [8]);
      expect(_trek({'city_ids': null}).cityIds, isNull);
      expect(_trek({'city_ids': {'a': 1}}).cityIds, isNull);
    });

    test('inclusions / activities: objects, plain names, unresolved ids', () {
      final trek = _trek({
        'inclusions': [
          {'id': 1, 'name': 'Meals', 'description': 'Veg'},
          {'id': '2', 'name': 'Tent'},
          'Guide',
          12, // an id the server could not resolve
          '  ',
        ],
        'activities': [
          {'id': 3, 'name': 'Camping'},
          'Bonfire',
          '7',
        ],
      });
      expect(trek.inclusions!.map((i) => i.name), ['Meals', 'Tent', 'Guide']);
      expect(trek.inclusions![1].id, 2);
      expect(trek.inclusions!.first.description, 'Veg');
      expect(trek.activities!.map((a) => a.name), ['Camping', 'Bonfire']);
      expect(trek.activities!.first.id, 3);
    });

    test('inclusions as a JSON-encoded string', () {
      final trek = _trek({'inclusions': '["Meals","Tent"]'});
      expect(trek.inclusions!.map((i) => i.name), ['Meals', 'Tent']);
    });

    test('exclusions and itinerary activities: unresolved ids left out, names kept', () {
      final trek = _trek({
        'exclusions': ['Flights', 9, {'name': 'Insurance'}],
        'itinerary_items': [
          {'id': 1, 'activities': ['Trek to base', 14, 'Camp']},
        ],
      });
      expect(trek.exclusions, ['Flights', 'Insurance']);
      expect(trek.itineraryItems!.single.activities, ['Trek to base', 'Camp']);
    });

    test('accommodation details.night: "2", 2.0 and 2', () {
      Details d(Object? night) => _trek({
            'accommodations': [
              {'id': 1, 'details': {'night': night, 'location': 'Base camp'}},
            ],
          }).accommodations!.single.details!;
      expect(d('2').night, 2);
      expect(d(2.0).night, 2);
      expect(d(2).night, 2);
      expect(d('second').night, isNull);
      expect(d(2).location, 'Base camp');
    });

    test('control: a well-formed trek is unchanged', () {
      final trek = _trek({
        'city_ids': [1, 2],
        'inclusions': [
          {'id': 1, 'name': 'Meals', 'description': null},
        ],
        'exclusions': ['Flights'],
        'activities': [
          {'id': 1, 'name': 'Camping'},
        ],
        'latest_reviews': [
          {'rating_value': 5},
        ],
      });
      expect(trek.cityIds, [1, 2]);
      expect(trek.inclusions!.single, const Inclusions(id: 1, name: 'Meals'));
      expect(trek.exclusions, ['Flights']);
      expect(trek.activities!.single, const Activities(id: 1, name: 'Camping'));
      expect(trek.latestReviews!.single.ratingValue, 5);
    });
  });

  group('E0-7 booking history Trek.city_ids and can_cancel', () {
    test('city_ids tolerant', () {
      final b = history.BookingHistoryData.fromJson({
        'id': 1,
        'trek': {'id': 2, 'title': 'Hampta', 'city_ids': ['1', 2, '[x]']},
      });
      expect(b.trek!.cityIds, [1, 2]);
      final c = history.BookingHistoryData.fromJson({
        'id': 1,
        'trek': {'id': 2, 'city_ids': '[3,4]'},
      });
      expect(c.trek!.cityIds, [3, 4]);
    });

    test('can_cancel as bool, 0/1 or text', () {
      bool? canCancel(Object? v) =>
          history.BookingHistoryData.fromJson({'id': 1, 'can_cancel': v}).canCancel;
      expect(canCancel(true), isTrue);
      expect(canCancel(false), isFalse);
      expect(canCancel(0), isFalse);
      expect(canCancel(1), isTrue);
      expect(canCancel('true'), isTrue);
      expect(canCancel(null), isNull);
    });
  });

  group('E0-7 Customer.emergencyContact (a JSON column)', () {
    String? contact(Object? v) =>
        Customer.fromJson({'id': 1, 'emergencyContact': v}).emergencyContact;

    test('string kept; object/array kept as JSON text; number as text', () {
      expect(contact('9876543210'), '9876543210');
      expect(
        contact({'name': 'Asha', 'phone': '9876543210'}),
        '{"name":"Asha","phone":"9876543210"}',
      );
      expect(contact([
        {'phone': '1'},
      ]), '[{"phone":"1"}]');
      expect(contact(9876543210), '9876543210');
      expect(contact(null), isNull);
    });

    test('a whole profile reply with an object emergencyContact parses', () {
      final m = UserProfileModal.fromJson({
        'success': true,
        'data': {
          'customer': {
            'id': 1,
            'name': 'Ravi',
            'emergencyContact': {'name': 'Asha', 'phone': '98'},
          },
        },
      });
      expect(m.data!.customer!.name, 'Ravi');
      expect(m.data!.customer!.emergencyContact, contains('Asha'));
    });
  });

  group('E0-5 calculate-fare coupon_rejected_code', () {
    test('is read when present, null when absent', () {
      final r = CalculateFareResponseModel.fromJson({
        'success': true,
        'coupon_rejected_reason': 'This coupon needs 4 travellers.',
        'coupon_rejected_code': 'COUPON_NOT_ELIGIBLE',
      });
      expect(r.couponRejectedCode, 'COUPON_NOT_ELIGIBLE');
      expect(r.couponRejectedReason, 'This coupon needs 4 travellers.');
      final none = CalculateFareResponseModel.fromJson({'success': true});
      expect(none.couponRejectedCode, isNull);
      expect(none.couponRejectedReason, isNull);
    });
  });

  group('json_converters', () {
    test('jsonToInt', () {
      expect(jsonToInt(3), 3);
      expect(jsonToInt(2.6), 3);
      expect(jsonToInt(' 7 '), 7);
      expect(jsonToInt(double.nan), isNull);
      expect(jsonToInt(true), isNull);
      expect(jsonToInt([1]), isNull);
    });

    test('jsonToNameList drops blanks and bare ids', () {
      expect(jsonToNameList(['a', ' ', '12', 12, {'name': 'b'}, {'id': 1}]), ['a', 'b']);
      expect(jsonToNameList(null), isNull);
      expect(jsonToNameList('not a list'), isNull);
    });
  });
}

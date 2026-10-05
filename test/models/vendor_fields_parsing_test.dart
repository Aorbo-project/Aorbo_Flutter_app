// Review C L11 + L12: vendor-entered JSON must not break the screens that
// read it.
// L11: a confirmed verify-payment reply whose booking carries, e.g., an
// amount sent as a number or a decimal commission rate made the whole parse
// throw -> the payment was treated as "unconfirmed".
// L12: an accommodation whose `details` is [] or a double-encoded string
// failed the whole trek-detail parse.

import 'package:arobo_app/controller/trek_controller.dart';
import 'package:arobo_app/freezed_models/json_converters.dart';
import 'package:arobo_app/freezed_models/treks/trek_detail_model.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:flutter_test/flutter_test.dart';

import '../trek_controller_test.dart' show setUpController, installFakeBackend;

Map<String, dynamic> _confirmedReply() => {
      'success': true,
      'next_action': 'SHOW_BOOKING_CONFIRMED',
      'data': {
        'id': 321,
        'booking_number': 'BI321',
        'total_amount': 10510, // a number where a String was expected
        'trek': {'id': 7, 'title': 'Kedarkantha', 'discount_value': 0},
        'vendor': {
          'id': 3,
          'company_info': {'commission_rate': 10.5, 'phone': 9876543210},
        },
      },
    };

Map<String, dynamic> _accommodation(Object? details) => {
      'id': '11',
      'trek_id': 7,
      'batch_id': '9',
      'type': 'Camp',
      'details': details,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('L11: verify-payment reply with odd vendor fields', () {
    test('readVerifyReply keeps the booking id and number', () {
      final m = TrekController.readVerifyReply(_confirmedReply());
      expect(m.data?.id, 321);
      expect(m.data?.bookingNumber, 'BI321');
    });

    test('verifyTrekOrder still reports the payment as CONFIRMED', () async {
      final c = await setUpController();
      installFakeBackend({NetworkUrl.verifyBooking: (_) => _confirmedReply()});
      final ok = await c.verifyTrekOrder(
        razorpayOrderId: 'order_1',
        razorpayPaymentId: 'pay_1',
        razorpaySignature: 'sig_1',
      );
      expect(ok, isTrue);
      expect(c.verifyOrderModal.value.data?.id, 321);
    });
  });

  group('L12: accommodation details', () {
    for (final entry in <String, Object?>{
      'an empty list': <dynamic>[],
      'a double-encoded string': '{"night": "2", "location": "Base camp"}',
      'garbage text': 'two nights',
      'a number': 3,
      'null': null,
    }.entries) {
      test('details as ${entry.key} does not break the parse', () {
        final a = Accommodations.fromJson(_accommodation(entry.value));
        expect(a.id, 11);
        expect(a.batchId, 9);
        if (entry.key == 'a double-encoded string') {
          expect(a.details?.night, 2);
          expect(a.details?.location, 'Base camp');
        }
      });
    }

    test('a proper object still parses', () {
      final a = Accommodations.fromJson(_accommodation({'night': 1, 'location': 'Juda ka Talab'}));
      expect(a.details?.night, 1);
    });

    test('jsonToMap', () {
      expect(jsonToMap({'a': 1}), {'a': 1});
      expect(jsonToMap('{"a":1}'), {'a': 1});
      expect(jsonToMap('[1]'), isNull);
      expect(jsonToMap('{broken'), isNull);
      expect(jsonToMap(7), isNull);
    });
  });
}

// CalculateFareResponseModel / BreakDownDataModel — verifies the Flutter
// model actually parses the real backend JSON shape from
// secureBookingController.js's calculateFare response (snake_case keys,
// money fields sent as either numbers or strings — every field here is
// typed `dynamic` in the model, so this test locks in that both shapes
// parse without throwing, matching the defensive `_toPaise` parsing the
// payment screen relies on downstream).

import 'package:arobo_app/freezed_models/booking/booking_data_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculateFareResponseModel.fromJson — realistic backend payload', () {
    test('parses a standard-policy response with numeric money fields', () {
      final json = {
        'success': true,
        'fareToken': 'tok123',
        'expires_at': '2026-08-08T12:00:00.000Z',
        'breakdown': {
          'original_base_fare': 10000,
          'traveler_count': 2,
          'vendor_discount': 0,
          'coupon_discount': 0,
          'final_base_fare': 10000,
          'gst': 500,
          'platform_fee': 10,
          'insurance_fee': 0,
          'cancellation_fee': 0,
          'final_amount': 10510,
          'cancellation_policy_type': 'standard',
          'advance_amount': 0,
          'amount_to_pay_now': 10510,
          'remaining_amount': 0,
        },
      };
      final model = CalculateFareResponseModel.fromJson(json);
      expect(model.success, true);
      expect(model.fareToken, 'tok123');
      expect(model.breakdown!.finalAmount, 10510);
      expect(model.breakdown!.amountToPayNow, 10510);
    });

    test('parses the SAME fields when the backend sends money as strings (a real, observed shape)', () {
      final json = {
        'success': true,
        'fareToken': 'tok123',
        'breakdown': {
          'final_amount': '10510.00',
          'amount_to_pay_now': '10510.00',
          'advance_amount': '0.00',
        },
      };
      final model = CalculateFareResponseModel.fromJson(json);
      // Fields are `dynamic` — the model itself does NOT coerce type, it
      // just passes the raw JSON value through. This locks in that
      // behavior so any future _toPaise-style consumer downstream must
      // keep doing its own defensive parsing (see payment_processing_screen.dart).
      expect(model.breakdown!.finalAmount, '10510.00');
      expect(model.breakdown!.finalAmount, isA<String>());
    });

    test('flexible-policy response with advance/remaining split parses correctly', () {
      final json = {
        'success': true,
        'fareToken': 'tok456',
        'breakdown': {
          'final_amount': 8410,
          'cancellation_policy_type': 'flexible',
          'advance_amount': 1998,
          'amount_to_pay_now': 2508,
          'remaining_amount': 6002,
        },
      };
      final model = CalculateFareResponseModel.fromJson(json);
      expect(model.breakdown!.cancellationPolicyType, 'flexible');
      expect(model.breakdown!.advanceAmount, 1998);
      expect(model.breakdown!.remainingAmount, 6002);
    });

    test('missing breakdown entirely -> null, does not throw', () {
      final model = CalculateFareResponseModel.fromJson({'success': false, 'message': 'Batch not found'});
      expect(model.success, false);
      expect(model.breakdown, isNull);
      expect(model.message, 'Batch not found');
    });

    test('unexpected extra fields from the backend are ignored, not a parse failure', () {
      final json = {
        'success': true,
        'fareToken': 'tok789',
        'breakdown': {'final_amount': 1000},
        'some_new_field_backend_added_later': 'whatever',
      };
      expect(() => CalculateFareResponseModel.fromJson(json), returnsNormally);
    });
  });

  group('CreateRazorpayRequestModel — outbound request shape (customer -> backend)', () {
    test('toJson uses snake_case keys the backend actually expects (fare_token, pay_full)', () {
      const model = CreateRazorpayRequestModel(fareToken: 'tok1', travelers: [], payFull: true);
      final json = model.toJson();
      expect(json['fare_token'], 'tok1');
      expect(json['pay_full'], true);
      expect(json.containsKey('fareToken'), false); // camelCase must NOT leak into the wire format
    });

    test('payFull defaults to false when not explicitly set', () {
      const model = CreateRazorpayRequestModel(fareToken: 'tok1', travelers: []);
      expect(model.payFull, false);
    });
  });
}

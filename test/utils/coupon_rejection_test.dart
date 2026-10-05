// Scan E0-5: the dropped-coupon snackbar shows the server's sentence, and
// never a raw code like FLEXIBLE_ADVANCE_EXCEEDS_FARE.

import 'package:arobo_app/utils/coupon_rejection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a real sentence is shown as it is (whatever the code)', () {
    const sentence = 'SQUAD25 needs at least 4 travellers.';
    expect(couponRejectionMessage(reason: sentence), sentence);
    expect(
      couponRejectionMessage(reason: sentence, code: 'COUPON_NOT_ELIGIBLE'),
      sentence,
    );
    expect(couponRejectionMessage(reason: '  $sentence  '), sentence);
  });

  test('a code in the reason (older servers) becomes friendly text', () {
    expect(
      couponRejectionMessage(reason: 'FLEXIBLE_ADVANCE_EXCEEDS_FARE'),
      flexibleAdvanceExceedsFareMessage,
    );
    expect(
      couponRejectionMessage(reason: 'COUPON_NOT_ELIGIBLE'),
      couponNotEligibleMessage,
    );
  });

  test('an empty reason uses coupon_rejected_code', () {
    expect(
      couponRejectionMessage(reason: '', code: 'FLEXIBLE_ADVANCE_EXCEEDS_FARE'),
      flexibleAdvanceExceedsFareMessage,
    );
    expect(
      couponRejectionMessage(reason: null, code: 'COUPON_NOT_ELIGIBLE'),
      couponNotEligibleMessage,
    );
  });

  test('an unknown code gets a generic line, never the code itself', () {
    final m = couponRejectionMessage(reason: 'SOME_NEW_CODE');
    expect(m, couponRemovedGenericMessage);
    expect(couponRejectionMessage(code: 'SOME_NEW_CODE'), couponRemovedGenericMessage);
  });

  test('nothing dropped → no message', () {
    expect(couponRejectionMessage(), isNull);
    expect(couponRejectionMessage(reason: '', code: ''), isNull);
    expect(couponRejectionMessage(reason: '   '), isNull);
  });

  test('looksLikeErrorCode', () {
    expect(looksLikeErrorCode('FLEXIBLE_ADVANCE_EXCEEDS_FARE'), isTrue);
    expect(looksLikeErrorCode('E42'), isTrue);
    expect(looksLikeErrorCode('Coupon not valid'), isFalse);
    expect(looksLikeErrorCode('NOT VALID'), isFalse);
  });
}

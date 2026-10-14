import 'package:arobo_app/controller/payment_failure_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  test('our code constants match the Razorpay plugin', () {
    expect(kRazorpayPaymentCancelled, Razorpay.PAYMENT_CANCELLED);
    expect(kRazorpayNetworkError, Razorpay.NETWORK_ERROR);
  });

  test('a closed checkout always gets the cancelled sentence, whatever Razorpay says', () {
    for (final raw in ['undefined', '', null, 'Payment cancelled by user', '{"error":{}}']) {
      expect(
        paymentFailureMessage(code: Razorpay.PAYMENT_CANCELLED, gatewayMessage: raw),
        paymentCancelledMessage,
        reason: '$raw',
      );
    }
  });

  test('a network failure gets the connection sentence', () {
    expect(
      paymentFailureMessage(code: Razorpay.NETWORK_ERROR, gatewayMessage: 'undefined'),
      paymentNetworkErrorMessage,
    );
  });

  test("other failures show Razorpay's text only when it is a readable sentence", () {
    expect(
      paymentFailureMessage(code: Razorpay.UNKNOWN_ERROR, gatewayMessage: 'Your bank declined the payment'),
      'Your bank declined the payment',
    );
    for (final junk in [
      'undefined',
      'null',
      '',
      '   ',
      'BAD_REQUEST_ERROR',
      '{"error":{"code":"BAD_REQUEST_ERROR"}}',
      'java.lang.IllegalStateException: boom',
      'Reason: undefined',
      'x' * 201,
    ]) {
      expect(
        paymentFailureMessage(code: Razorpay.UNKNOWN_ERROR, gatewayMessage: junk),
        paymentNotCompletedMessage,
        reason: junk,
      );
    }
  });

  test('the cancelled sentence never promises "not charged" (a UPI payment may still be settling)', () {
    expect(paymentCancelledMessage.toLowerCase(), isNot(contains('not been charged')));
    expect(paymentCancelledMessage.toLowerCase(), isNot(contains("haven't been charged")));
  });
}

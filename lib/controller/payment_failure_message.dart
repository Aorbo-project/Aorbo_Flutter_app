/// What the payment screen says when Razorpay Checkout reports a failure.
///
/// Razorpay's own `message` is not fit to show as-is: when the customer backs
/// out of Checkout it can arrive as the literal word "undefined" (seen on a
/// real phone 14 Oct 2026: "Something went wrong / undefined"), and other
/// failures carry raw JSON. So the reason is chosen from the error code, and
/// Razorpay's text is used only when it is a plain, readable sentence.
library;

/// Razorpay Checkout error codes (razorpay_flutter `Razorpay.*`).
const int kRazorpayNetworkError = 0;
const int kRazorpayPaymentCancelled = 2;

const String paymentFailedTitle = 'Something went wrong';
const String paymentCancelledTitle = 'Payment cancelled';

/// Razorpay also reports "cancelled" when the customer closes Checkout while a
/// UPI payment is still settling, so this never says "you were not charged":
/// such a payment is confirmed into the booking or refunded by the server.
const String paymentCancelledMessage =
    'No booking was made. If any money was debited, we will confirm your '
    'booking or refund it automatically. Tap RETRY to try again.';
const String paymentNetworkErrorMessage =
    "We couldn't reach the payment gateway. Check your internet connection "
    'and tap RETRY.';
const String paymentNotCompletedMessage =
    'The payment was not completed. Please tap RETRY to try again.';

/// The line shown under the title for a Checkout failure with [code] and
/// Razorpay's [gatewayMessage].
String paymentFailureMessage({required int? code, String? gatewayMessage}) {
  if (code == kRazorpayPaymentCancelled) return paymentCancelledMessage;
  if (code == kRazorpayNetworkError) return paymentNetworkErrorMessage;
  final text = gatewayMessage?.trim() ?? '';
  return isReadableGatewayMessage(text) ? text : paymentNotCompletedMessage;
}

/// A gateway message a customer can read: a short plain sentence, not
/// "undefined" / "null", JSON, a stack trace or a bare code.
bool isReadableGatewayMessage(String text) {
  if (text.isEmpty || text.length > 200) return false;
  final lower = text.toLowerCase();
  if (lower == 'undefined' || lower == 'null' || lower == 'error') return false;
  if (text.startsWith('{') || text.startsWith('[')) return false;
  if (lower.contains('exception') || lower.contains('undefined')) return false;
  // Needs at least two words with letters ("BAD_REQUEST_ERROR" is not one).
  return RegExp(r'[A-Za-z]+\s+[A-Za-z]+').hasMatch(text);
}

/// What a verify-payment reply means for the app (see
/// TrekController.verifyTrekOrder).
enum VerifyPaymentOutcome {
  /// A booking exists and the reply carries it (data with a booking id).
  confirmed,

  /// The payment could not become a booking and was refunded.
  /// Never shown as "booking confirmed".
  refunded,

  /// Anything else: a failure, no booking data yet, an unknown next_action.
  /// Not confirmed — the payment screen falls back to polling the order
  /// status, which settles it either way.
  unconfirmed,
}

/// Shown when a refunded reply carries no message of its own.
const String paymentRefundedFallbackMessage =
    'This payment could not be turned into a booking and has been refunded '
    'to your original payment method. Refunds usually take 5–7 business days.';

/// Reads a verify-payment reply.
///
/// - `refunded: true`, `next_action: SHOW_PAYMENT_REFUNDED` or
///   `code: PAYMENT_REFUNDED` → [VerifyPaymentOutcome.refunded], whatever
///   `success` says.
/// - `success: true` + `SHOW_BOOKING_CONFIRMED` (or no next_action) + a
///   booking in `data` (with an id) → [VerifyPaymentOutcome.confirmed].
///   `success: true` with no booking data is NOT a confirmation.
/// - everything else → [VerifyPaymentOutcome.unconfirmed].
VerifyPaymentOutcome classifyVerifyReply(Object? reply) {
  if (reply is! Map) return VerifyPaymentOutcome.unconfirmed;
  if (reply['refunded'] == true ||
      reply['next_action'] == 'SHOW_PAYMENT_REFUNDED' ||
      reply['code'] == 'PAYMENT_REFUNDED') {
    return VerifyPaymentOutcome.refunded;
  }
  if (reply['success'] != true) return VerifyPaymentOutcome.unconfirmed;
  final nextAction = reply['next_action'] ?? 'SHOW_BOOKING_CONFIRMED';
  if (nextAction != 'SHOW_BOOKING_CONFIRMED') {
    return VerifyPaymentOutcome.unconfirmed;
  }
  final data = reply['data'];
  if (data is! Map || data['id'] == null) {
    return VerifyPaymentOutcome.unconfirmed;
  }
  return VerifyPaymentOutcome.confirmed;
}

/// The message to show for a refunded reply.
String refundedReplyMessage(Object? reply) {
  final m = reply is Map ? reply['message'] : null;
  return (m is String && m.trim().isNotEmpty)
      ? m.trim()
      : paymentRefundedFallbackMessage;
}

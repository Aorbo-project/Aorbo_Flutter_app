// The message shown when calculate-fare drops a coupon (the fare still comes
// back, discount-free). The server's coupon_rejected_reason is a sentence for
// people; older servers sometimes put a bare code there instead, and
// coupon_rejected_code carries the stable code.

const String couponNotEligibleMessage =
    "This coupon doesn't apply to your booking as it is now, so it was "
    'removed. The price shown is without it.';

const String flexibleAdvanceExceedsFareMessage =
    "This coupon can't be used with Flexible booking on this trek: it would "
    'bring the price below the advance. You can continue without the coupon.';

const String couponRemovedGenericMessage =
    "This coupon couldn't be applied, so it was removed. The price shown is "
    'without it.';

const Map<String, String> _knownCodes = {
  'COUPON_NOT_ELIGIBLE': couponNotEligibleMessage,
  'FLEXIBLE_ADVANCE_EXCEEDS_FARE': flexibleAdvanceExceedsFareMessage,
};

final RegExp _codeLike = RegExp(r'^[A-Z0-9_]+$');

/// True for a machine code like `FLEXIBLE_ADVANCE_EXCEEDS_FARE` (all caps,
/// digits and underscores, no spaces) rather than a sentence.
bool looksLikeErrorCode(String s) => _codeLike.hasMatch(s.trim());

/// What to tell the customer about a dropped coupon, or null when nothing
/// was dropped. A real sentence in [reason] is shown as it is; an empty or
/// code-like reason is replaced by friendly text for the code ([code], or
/// the reason itself when it is a code).
String? couponRejectionMessage({String? reason, String? code}) {
  final r = reason?.trim() ?? '';
  final c = code?.trim() ?? '';
  if (r.isNotEmpty && !looksLikeErrorCode(r)) return r;
  final key = c.isNotEmpty ? c : r;
  if (key.isEmpty) return null;
  return _knownCodes[key.toUpperCase()] ?? couponRemovedGenericMessage;
}

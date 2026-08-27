import 'package:flutter/services.dart';

/// The login field already shows a fixed "+91" prefix outside the box, but
/// users often paste/type a number that still carries its own country code
/// (e.g. pasted from Contacts as "+91 98765 43210" or "919876543210").
/// Filtering to digits-only and then simply keeping the *first* 10 digits
/// corrupts that number — it keeps the "91" and drops the real last two
/// digits. Once there are more than 10 digits, the real subscriber number is
/// always the trailing 10, regardless of what country-code/junk precedes it,
/// so keeping the *last* 10 digits instead handles a leading "+91", "91", or
/// "0" the same way, without needing to special-case each prefix.
class IndianMobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');

    String trimmed;
    if (digits.length > 10) {
      // "Keep the last 10" is right for a paste (many digits arrive in
      // one edit) but wrong for someone just typing an 11th digit after
      // an already-complete number — that used to silently shift the
      // whole window and drop the first digit, which reads as the field
      // corrupting what you already typed, not as "capped at 10". A
      // paste jumps the digit count by more than one in a single edit;
      // a keystroke adds exactly one. Only slide the window for the
      // former — for the latter, just reject the extra keystroke and
      // stay at the 10 digits already there.
      final isPasteLikeJump = digits.length - oldDigits.length > 1;
      trimmed = isPasteLikeJump ? digits.substring(digits.length - 10) : oldDigits;
    } else {
      trimmed = digits;
    }

    if (trimmed == newValue.text) return newValue;
    return TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
  }
}

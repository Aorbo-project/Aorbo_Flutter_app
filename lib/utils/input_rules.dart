import 'package:flutter/services.dart';

/// What each kind of field accepts (17 Oct 2026: the app took
/// "€£€¥=}}\%®✓]<>©®{" in emails, coupon codes and searches). Text typed in
/// the app is never executed, but junk should not be sent, stored, shown to
/// vendors or printed on tickets. Blocks the characters while typing; the
/// server checks the same rules (Backend utils/inputRules.js), since the app
/// can be bypassed.
class InputRules {
  InputRules._();

  /// Names: letters in any script, spaces and . ' -  (max 60).
  static final List<TextInputFormatter> personName = [
    FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M} .'\-]", unicode: true)),
    _noOrdinals,
    LengthLimitingTextInputFormatter(60),
  ];

  /// Searches (places, treks, states): letters, digits, spaces and . , ' - ( ) & /  (max 60).
  static final List<TextInputFormatter> searchText = [
    FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M}\p{N} .,'\-()&/]", unicode: true)),
    _noOrdinals,
    LengthLimitingTextInputFormatter(60),
  ];

  /// Coupon codes: A–Z, 0–9, - and _, shown in capitals (max 30).
  static final List<TextInputFormatter> couponCode = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_\-]')),
    LengthLimitingTextInputFormatter(30),
    const _UpperCase(),
  ];

  /// Emails: the characters an address can have (max 100).
  static final List<TextInputFormatter> email = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9._%+\-@]')),
    LengthLimitingTextInputFormatter(100),
  ];

  /// Free text (reasons, reviews, messages): anything readable except < > and
  /// control characters.
  static List<TextInputFormatter> freeText({int max = 1000}) => [
        FilteringTextInputFormatter.deny(RegExp(r'[<>\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]')),
        LengthLimitingTextInputFormatter(max),
      ];

  /// º and ª are "letters" to Unicode but symbols on a keyboard.
  static final _noOrdinals = FilteringTextInputFormatter.deny(RegExp('[ªº]'));

  static final RegExp _name = RegExp(r"^[\p{L}\p{M}][\p{L}\p{M} .'\-]*$", unicode: true);
  static final RegExp _email = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._%+\-]{0,63}@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,24}$');

  /// The same sentences as the server (utils/inputRules.js), or null.
  static String? nameProblem(String? value, {String label = 'Name'}) {
    final v = (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (v.length < 2 || v.length > 60) return '$label must be 2–60 characters.';
    if (!_name.hasMatch(v) || v.contains(RegExp('[ªº]'))) return "$label can have only letters, spaces and . ' -";
    return null;
  }

  static String? emailProblem(String? value) {
    final v = (value ?? '').trim();
    if (v.length > 100 || !_email.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }
}

class _UpperCase extends TextInputFormatter {
  const _UpperCase();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

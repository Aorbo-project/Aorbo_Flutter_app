import 'package:intl/intl.dart';

/// Centralized IST (Indian Standard Time, UTC+5:30, no DST) conversion for
/// every user-facing date/time shown in the app.
///
/// The backend's system standard is UTC — all stored/returned timestamps are
/// UTC instants (ISO 8601, with or without a trailing 'Z'/offset). This app
/// is India-only, so display must always be IST regardless of the device's
/// own timezone/locale — never `.toLocal()`, which depends on the phone's
/// system settings and would show the wrong time for a traveling user.
class ISTDateUtils {
  ISTDateUtils._();

  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  /// Parses [input] (ISO 8601 string, or a Date already produced by
  /// `DateTime.parse`) as a UTC instant, then shifts it by +5:30 so its
  /// wall-clock fields (year/month/day/hour/minute) represent IST directly.
  /// The returned DateTime is still flagged `isUtc: true` internally — that's
  /// intentional, it prevents `DateFormat`/anything else from re-applying a
  /// device-local conversion on top. Never call `.toLocal()` on the result.
  static DateTime? toIST(dynamic input) {
    if (input == null) return null;
    DateTime? utc;
    if (input is DateTime) {
      utc = input.isUtc ? input : input.toUtc();
    } else {
      final str = input.toString().trim();
      if (str.isEmpty) return null;
      try {
        final parsed = DateTime.parse(str);
        // Bare "YYYY-MM-DD" or "YYYY-MM-DD HH:MM:SS" (no 'Z'/offset) parses as
        // device-local per Dart's spec; since the backend's standard is UTC,
        // treat it as UTC by reading back its raw fields instead of trusting
        // whatever local-offset DateTime.parse silently applied.
        final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(str);
        utc = hasZone
            ? parsed.toUtc()
            : DateTime.utc(parsed.year, parsed.month, parsed.day,
                parsed.hour, parsed.minute, parsed.second, parsed.millisecond);
      } catch (_) {
        return null;
      }
    }
    return utc.add(_istOffset);
  }

  /// e.g. "10 Jul 2026"
  static String formatDate(dynamic input, {String fallback = '-'}) {
    final ist = toIST(input);
    if (ist == null) return fallback;
    return DateFormat('dd MMM yyyy').format(ist);
  }

  /// e.g. "10 Jul 2026, 11:30 PM"
  static String formatDateTime(dynamic input, {String fallback = '-'}) {
    final ist = toIST(input);
    if (ist == null) return fallback;
    return DateFormat('dd MMM yyyy, hh:mm a').format(ist);
  }

  /// e.g. "11:30 PM"
  static String formatTime(dynamic input, {String fallback = '-'}) {
    final ist = toIST(input);
    if (ist == null) return fallback;
    return DateFormat('hh:mm a').format(ist);
  }

  /// e.g. "22/12/2024 03:30 PM" — matches the legacy AuthUtils.formatDateTime pattern.
  static String formatDateTimeSlash(dynamic input, {String fallback = '-'}) {
    final ist = toIST(input);
    if (ist == null) return fallback;
    return DateFormat('dd/MM/yyyy hh:mm a').format(ist);
  }

  /// Format with a caller-supplied pattern, still IST-shifted.
  static String formatCustom(dynamic input, String pattern, {String fallback = '-'}) {
    final ist = toIST(input);
    if (ist == null) return fallback;
    return DateFormat(pattern).format(ist);
  }
}

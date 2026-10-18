import 'package:intl/intl.dart';

/// How the website's treks (aorbotreks.com `GET /api/treks/`) read in the app:
/// the same wording as the website's own cards (owner, 18 Oct 2026: "₹15000
/// ONWARDS" and "3D/2N, 4D/3N" on the app vs "₹15,000 onwards" and
/// "3 Days / 2 Nights" on the site). One place, so the Popular Treks cards and
/// the trek detail screen always agree.
class FeaturedTrekFormat {
  FeaturedTrekFormat._();

  static final NumberFormat _inr = NumberFormat.decimalPattern('en_IN');

  /// 15000 / "15000" / "15,000" -> "15,000"; null when it isn't a price.
  static String? amount(Object? price) {
    final n = num.tryParse(price?.toString().replaceAll(',', '').trim() ?? '');
    if (n == null || n <= 0) return null;
    return _inr.format(n.round());
  }

  /// "₹15,000"; null when it isn't a price.
  static String? rupees(Object? price) {
    final a = amount(price);
    return a == null ? null : '₹$a';
  }

  static final RegExp _dn = RegExp(r'^(\d+)\s*D(?:\s*[/-]\s*(\d+)\s*N)?$', caseSensitive: false);
  static final RegExp _daysWord = RegExp(r'^(\d+)\s*days?$', caseSensitive: false);

  /// "3D/2N" -> "3 Days / 2 Nights", "1D" -> "1 Day", "6 Days" -> "6 Days"; anything else as typed.
  static String durationOption(String raw) {
    final text = raw.trim();
    final m = _dn.firstMatch(text);
    if (m != null) {
      final d = int.parse(m.group(1)!);
      final n = m.group(2) == null ? null : int.parse(m.group(2)!);
      final days = '$d ${d == 1 ? 'Day' : 'Days'}';
      return n == null ? days : '$days / $n ${n == 1 ? 'Night' : 'Nights'}';
    }
    final w = _daysWord.firstMatch(text);
    if (w != null) {
      final d = int.parse(w.group(1)!);
      return '$d ${d == 1 ? 'Day' : 'Days'}';
    }
    return text;
  }

  /// "3D/2N,4D/3N, 5D/4N Days" -> ["3 Days / 2 Nights", "4 Days / 3 Nights", "5 Days / 4 Nights"].
  static List<String> durationOptions(String? raw) => (raw ?? '')
      .replaceAll(RegExp(r'\s*days\s*$', caseSensitive: false), '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .map(durationOption)
      .toList();

  /// One short line for a card: "3 Days" or "2–5 Days"; null when unknown.
  static String? durationRange(String? raw) {
    final days = RegExp(r'(\d+)\s*D', caseSensitive: false)
        .allMatches(raw ?? '')
        .map((m) => int.parse(m.group(1)!))
        .toList();
    if (days.isEmpty) {
      final only = int.tryParse((raw ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
      return only == null ? null : '$only ${only == 1 ? 'Day' : 'Days'}';
    }
    days.sort();
    final lo = days.first, hi = days.last;
    return lo == hi ? '$lo ${lo == 1 ? 'Day' : 'Days'}' : '$lo–$hi Days';
  }

  /// "THU, FRI, SAT" / "fri,sat" -> ["Thu", "Fri", "Sat"]; "DAILY" -> ["Daily"].
  static List<String> weekdays(String? raw) => (raw ?? '')
      .split(RegExp(r'[,/]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}')
      .toList();
}

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

  static String _count(int n, String unit) => '$n ${n == 1 ? unit : '${unit}s'}';

  // The website's rule (aorbo-frontend/src/utils/format.js durationOptions): every
  // option in full, duplicates removed, shortest first; never a range like "3-5 days"
  // (the owner had that removed from the website).
  static final RegExp _option =
      RegExp(r'(\d+)\s*D(?:ays?)?\b\s*(?:[/-]\s*(\d+)\s*N(?:ights?)?\b)?', caseSensitive: false);

  /// "3D/2N, 4D/3N,5D/4N" -> ["3 Days / 2 Nights", "4 Days / 3 Nights", "5 Days / 4 Nights"].
  static List<String> durationOptions(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return [];
    if (RegExp(r'^\d+$').hasMatch(text)) return [_count(int.parse(text), 'Day')];
    final options = <String>[];
    for (final m in _option.allMatches(text)) {
      final d = int.parse(m.group(1)!);
      final n = m.group(2) == null ? null : int.parse(m.group(2)!);
      final o = n == null ? _count(d, 'Day') : '${_count(d, 'Day')} / ${_count(n, 'Night')}';
      if (!options.contains(o)) options.add(o);
    }
    if (options.isEmpty) return [text];
    options.sort((x, y) => int.parse(x.split(' ').first).compareTo(int.parse(y.split(' ').first)));
    return options;
  }

  /// Every option in full, as the website writes it: "2 Days / 1 Night, 3 Days / 2 Nights".
  static String durationText(String? raw) => durationOptions(raw).join(', ');

  /// "THU, FRI, SAT" / "fri,sat" -> ["Thu", "Fri", "Sat"]; "DAILY" -> ["Daily"].
  static List<String> weekdays(String? raw) => (raw ?? '')
      .split(RegExp(r'[,/]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}')
      .toList();
}

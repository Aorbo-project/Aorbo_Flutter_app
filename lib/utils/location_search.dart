/// Search for the From / To picker (lib/screens/source_location_screen.dart).
///
/// Scan D1: the fuzzy pass and the empty state's "Did you mean" ran on the
/// UI thread at 10-16 ms per pass on a desktop CPU (several dropped frames
/// on a budget phone), and "Did you mean" ran inside build on EVERY
/// keystroke. Same algorithm and the same results (test/location/
/// location_search_test.dart compares them with the previous code over the
/// real 6,578-city list), without the per-cell allocations:
///  - the edit distance compares code units with plain `<` and reuses two
///    rows instead of allocating a 3-item list + closure per cell;
///  - each entry's lower-case name and word tokens are computed once.
library;

import 'package:flutter/foundation.dart' show visibleForTesting;

/// How many times [didYouMean] ran (tests: it must run once per settled
/// query, never once per rebuild / keystroke).
@visibleForTesting
int debugDidYouMeanCalls = 0;

/// One pickable location: its search key, words, popular flag and (treks)
/// the state shown as trailing context.
class LocationEntry {
  LocationEntry({
    required this.id,
    required this.name,
    required this.normalized,
    this.isPopular = false,
    this.state,
  })  : lowerName = name.toLowerCase(),
        tokens = List<String>.unmodifiable([
          for (final t in normalized.split(' '))
            if (t.isNotEmpty) t,
        ]);

  final int id;
  final String name;
  final String normalized;
  final bool isPopular;
  final String? state;

  /// `name.toLowerCase()`, once.
  final String lowerName;

  /// The non-empty words of [normalized], once.
  final List<String> tokens;
}

const Map<String, String> _diacritics = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', 'ē': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', 'ī': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o', 'ō': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', 'ū': 'u',
  'ñ': 'n', 'ń': 'n', 'ç': 'c', 'ć': 'c', 'ś': 's', 'š': 's',
  'ý': 'y', 'ÿ': 'y', 'ź': 'z', 'ż': 'z', 'ř': 'r', 'ŕ': 'r',
  'ł': 'l', 'đ': 'd', 'ß': 'ss',
};

final RegExp _diacriticPattern =
    RegExp('[${_diacritics.keys.map(RegExp.escape).join()}]');
final RegExp _nonAlnum = RegExp(r'[^a-z0-9\s]');
final RegExp _spaces = RegExp(r'\s+');

/// Lower case, accents folded, punctuation to spaces, spaces collapsed.
String normalizeLocationName(String s) {
  var out = s.toLowerCase().trim();
  out = out.replaceAllMapped(_diacriticPattern, (m) => _diacritics[m[0]!] ?? '');
  out = out.replaceAll(_nonAlnum, ' ');
  out = out.replaceAll(_spaces, ' ');
  return out.trim();
}

// Reused rows for [levenshteinCapped] (the picker runs on one isolate).
List<int> _prevRow = List<int>.filled(64, 0);
List<int> _currRow = List<int>.filled(64, 0);

/// Edit distance between [a] and [b], or `max + 1` as soon as it must be
/// larger than [max].
int levenshteinCapped(String a, String b, int max) {
  if (a == b) return 0;
  final la = a.length, lb = b.length;
  if ((la - lb).abs() > max) return max + 1;
  if (la == 0) return lb;
  if (lb == 0) return la;
  if (_prevRow.length <= lb) {
    _prevRow = List<int>.filled(lb + 1, 0);
    _currRow = List<int>.filled(lb + 1, 0);
  }
  var prev = _prevRow;
  var curr = _currRow;
  for (var j = 0; j <= lb; j++) {
    prev[j] = j;
  }
  for (var i = 1; i <= la; i++) {
    curr[0] = i;
    var rowMin = i;
    final ci = a.codeUnitAt(i - 1);
    for (var j = 1; j <= lb; j++) {
      var v = prev[j] + 1;
      final left = curr[j - 1] + 1;
      if (left < v) v = left;
      final diag = prev[j - 1] + (ci == b.codeUnitAt(j - 1) ? 0 : 1);
      if (diag < v) v = diag;
      curr[j] = v;
      if (v < rowMin) rowMin = v;
    }
    if (rowMin > max) return max + 1;
    final tmp = prev;
    prev = curr;
    curr = tmp;
  }
  return prev[lb];
}

class _Scored<T> {
  _Scored(this.entry, this.score);
  final T entry;
  final int score;
}

int _bestDistance(String q, LocationEntry e, int maxDist) {
  var best = levenshteinCapped(q, e.normalized, maxDist);
  for (final token in e.tokens) {
    if (best == 0) break;
    final d = levenshteinCapped(q, token, maxDist);
    if (d < best) best = d;
  }
  return best;
}

/// The picker's list for [rawQuery]: names starting with it, then a word
/// starting with it, then containing it; when that is fewer than 6, close
/// spellings (1 edit for 1-3 letters, else 2) are added, nearest first.
List<T> filterLocations<T extends LocationEntry>(List<T> source, String rawQuery) {
  final q = normalizeLocationName(rawQuery);
  if (q.isEmpty) return source;
  final prefix = <T>[];
  final wordPrefix = <T>[];
  final substring = <T>[];
  for (final e in source) {
    final norm = e.normalized;
    if (norm.startsWith(q)) {
      prefix.add(e);
      continue;
    }
    var wp = false;
    for (final token in e.tokens) {
      if (token.startsWith(q)) {
        wp = true;
        break;
      }
    }
    if (wp) {
      wordPrefix.add(e);
    } else if (norm.contains(q)) {
      substring.add(e);
    }
  }
  final direct = [...prefix, ...wordPrefix, ...substring];
  if (direct.length >= 6) return direct;
  final fuzzy = <_Scored<T>>[];
  final seen = {for (final e in direct) e.lowerName};
  final maxDist = q.length <= 3 ? 1 : 2;
  for (final e in source) {
    if (seen.contains(e.lowerName)) continue;
    final best = _bestDistance(q, e, maxDist);
    if (best <= maxDist) fuzzy.add(_Scored(e, best));
  }
  fuzzy.sort((a, b) => a.score.compareTo(b.score));
  return [...direct, ...fuzzy.map((s) => s.entry)];
}

/// Relaxed fuzzy pass for the empty state — up to 3 "Did you mean…?" names.
List<T> didYouMean<T extends LocationEntry>(List<T> entries, String rawQuery) {
  debugDidYouMeanCalls++;
  final q = normalizeLocationName(rawQuery);
  if (q.isEmpty) return const [];
  final maxDist = q.length <= 4 ? 2 : 3;
  final scored = <_Scored<T>>[];
  for (final e in entries) {
    final best = _bestDistance(q, e, maxDist);
    if (best <= maxDist) scored.add(_Scored(e, best));
  }
  scored.sort((a, b) => a.score.compareTo(b.score));
  if (scored.length > 3) scored.removeRange(3, scored.length);
  return [for (final s in scored) s.entry];
}

// Scan D1: the From/To picker's search was rewritten for speed. These tests
// prove it gives IDENTICAL results to the previous code (copied verbatim
// below as the reference) over the real city list (6,578 names from
// /api/v1/cities plus a few accented ones), and that it is faster.

import 'dart:io';
import 'dart:math';

import 'package:arobo_app/utils/location_search.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Reference: the previous implementation (source_location_screen.dart) ──
class _OldDiacritics {
  static final map = <String, String>{
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', 'ē': 'e',
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', 'ī': 'i',
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o', 'ō': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', 'ū': 'u',
    'ñ': 'n', 'ń': 'n', 'ç': 'c', 'ć': 'c', 'ś': 's', 'š': 's',
    'ý': 'y', 'ÿ': 'y', 'ź': 'z', 'ż': 'z', 'ř': 'r', 'ŕ': 'r',
    'ł': 'l', 'đ': 'd', 'ß': 'ss',
  };
  static final pattern = RegExp(
    '[${map.keys.map((c) => RegExp.escape(c)).join()}]',
  );
}

String _oldNormalized(String input) {
  var s = input.toLowerCase().trim();
  s = s.replaceAllMapped(_OldDiacritics.pattern, (m) => _OldDiacritics.map[m[0]!] ?? '');
  s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  return s.trim();
}

int _oldLevenshteinCapped(String a, String b, int max) {
  if (a == b) return 0;
  final la = a.length, lb = b.length;
  if ((la - lb).abs() > max) return max + 1;
  if (la == 0) return lb;
  if (lb == 0) return la;
  var prev = List<int>.generate(lb + 1, (i) => i);
  var curr = List<int>.filled(lb + 1, 0);
  for (var i = 1; i <= la; i++) {
    curr[0] = i;
    var rowMin = i;
    final ci = a[i - 1];
    for (var j = 1; j <= lb; j++) {
      final cost = ci == b[j - 1] ? 0 : 1;
      final v = [
        prev[j] + 1,
        curr[j - 1] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
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

class _OldEntry {
  final int id;
  final String name;
  final String normalized;
  const _OldEntry(this.id, this.name, this.normalized);
}

class _OldScored {
  final _OldEntry entry;
  final int score;
  const _OldScored(this.entry, this.score);
}

List<_OldEntry> _oldComputeFiltered(List<_OldEntry> source, String rawQuery) {
  final q = _oldNormalized(rawQuery);
  if (q.isEmpty) return source;
  final prefix = <_OldEntry>[];
  final wordPrefix = <_OldEntry>[];
  final substring = <_OldEntry>[];
  for (final e in source) {
    final norm = e.normalized;
    if (norm.startsWith(q)) {
      prefix.add(e);
      continue;
    }
    var wp = false;
    for (final token in norm.split(' ')) {
      if (token.isEmpty) continue;
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
  final fuzzy = <_OldScored>[];
  final seen = direct.map((e) => e.name.toLowerCase()).toSet();
  final maxDist = q.length <= 3 ? 1 : 2;
  for (final e in source) {
    if (seen.contains(e.name.toLowerCase())) continue;
    var best = _oldLevenshteinCapped(q, e.normalized, maxDist);
    for (final token in e.normalized.split(' ')) {
      if (token.isEmpty) continue;
      final d = _oldLevenshteinCapped(q, token, maxDist);
      if (d < best) best = d;
    }
    if (best <= maxDist) fuzzy.add(_OldScored(e, best));
  }
  fuzzy.sort((a, b) => a.score.compareTo(b.score));
  return [...direct, ...fuzzy.map((s) => s.entry)];
}

List<_OldEntry> _oldDidYouMean(List<_OldEntry> entries, String rawQuery) {
  final q = _oldNormalized(rawQuery);
  if (q.isEmpty) return const [];
  final maxDist = q.length <= 4 ? 2 : 3;
  final scored = <_OldScored>[];
  for (final e in entries) {
    var best = _oldLevenshteinCapped(q, e.normalized, maxDist);
    for (final token in e.normalized.split(' ')) {
      if (token.isEmpty) continue;
      final d = _oldLevenshteinCapped(q, token, maxDist);
      if (d < best) best = d;
    }
    if (best <= maxDist) scored.add(_OldScored(e, best));
  }
  scored.sort((a, b) => a.score.compareTo(b.score));
  if (scored.length > 3) scored.removeRange(3, scored.length);
  return [for (final s in scored) s.entry];
}
// ── end of reference ─────────────────────────────────────────────────────

const _queries = [
  '', '  ', 'h', 'hy', 'hyd', 'hyderab', 'hydrabad', 'Hyderabad', 'bangalor',
  'bengaluru', 'vizag', 'xqzt', 'hydrabaddd', 'qwertyu', 'kodai', 'kodaikanal',
  'una', 'sao tome', 'pondicherry', 'pondichery', '4 arm', 'ab', 'Mumbai',
  'mumabi', 'dehradun', 'dehradoon', 'rishikesh', 'rishikes', 'manali', 'leh',
  'kasol', 'coorg', 'ooty', 'munnar', 'darjeling', 'gangtok', 'shimla', 'simla',
  'tosh', 'ar', 'aar', 'a', 'z', 'zz', 'new delhi', 'delhi ncr', 'navi mumbai',
  'kolkatta', 'calcutta', 'chennai', 'madras', 'puri', 'pune', 'goa', 'gao',
  'jaipur', 'jaypur', 'udaipur', 'ladakh', 'spiti', 'kedarnath', 'kedarkanta',
  'Ūnā', '(kharwali)', '7lc', 'abu', 'mount abu', 'a b', 'x y z',
];

void main() {
  final names = File('test/fixtures/city_names.txt')
      .readAsLinesSync()
      .where((l) => l.trim().isNotEmpty)
      .toList();

  // Built the way the picker builds its cache (dedupe by lower-case name,
  // sort by lower-case name).
  List<_OldEntry> oldEntries() {
    final seen = <String>{};
    final out = <_OldEntry>[];
    for (var i = 0; i < names.length; i++) {
      final name = names[i].trim();
      if (!seen.add(name.toLowerCase())) continue;
      out.add(_OldEntry(i + 1, name, _oldNormalized(name)));
    }
    out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  List<LocationEntry> newEntries() {
    final seen = <String>{};
    final out = <LocationEntry>[];
    for (var i = 0; i < names.length; i++) {
      final name = names[i].trim();
      if (!seen.add(name.toLowerCase())) continue;
      out.add(LocationEntry(id: i + 1, name: name, normalized: normalizeLocationName(name)));
    }
    out.sort((a, b) => a.lowerName.compareTo(b.lowerName));
    return out;
  }

  final olds = oldEntries();
  final news = newEntries();

  test('the fixture is the real list (6,500+ names)', () {
    expect(names.length, greaterThan(6500));
    expect(news.length, olds.length);
  });

  test('normalization is identical for every name', () {
    for (final n in [...names, 'ÀÉÎÕÜ', '  São  Tomé!! ', 'Straße', 'a--b__c']) {
      expect(normalizeLocationName(n), _oldNormalized(n), reason: n);
    }
  });

  test('cache order is identical', () {
    expect([for (final e in news) e.id], [for (final e in olds) e.id]);
  });

  test('edit distance is identical (random pairs, caps 1-3)', () {
    final rnd = Random(42);
    for (var k = 0; k < 4000; k++) {
      final a = olds[rnd.nextInt(olds.length)].normalized;
      final b = rnd.nextBool()
          ? olds[rnd.nextInt(olds.length)].normalized
          : a.substring(0, rnd.nextInt(a.length + 1));
      final max = 1 + rnd.nextInt(3);
      expect(levenshteinCapped(a, b, max), _oldLevenshteinCapped(a, b, max), reason: '$a | $b | $max');
    }
    // long strings (row buffers grow)
    final long = 'x' * 200;
    expect(levenshteinCapped(long, '${long}y', 2), _oldLevenshteinCapped(long, '${long}y', 2));
  });

  test('search results are identical for every query', () {
    for (final q in _queries) {
      expect(
        [for (final e in filterLocations(news, q)) e.id],
        [for (final e in _oldComputeFiltered(olds, q)) e.id],
        reason: 'query "$q"',
      );
    }
  });

  test('"Did you mean" is identical for every query', () {
    for (final q in _queries) {
      expect(
        [for (final e in didYouMean(news, q)) e.id],
        [for (final e in _oldDidYouMean(olds, q)) e.id],
        reason: 'query "$q"',
      );
    }
  });

  test('the fuzzy passes are faster than before', () {
    const fuzzyQueries = ['hyderab', 'hydrabad', 'bangalor', 'hydrabaddd', 'qwertyu'];
    int time(void Function() f) {
      final sw = Stopwatch()..start();
      f();
      return sw.elapsedMicroseconds;
    }

    // Warm up both (JIT).
    for (var i = 0; i < 3; i++) {
      for (final q in fuzzyQueries) {
        filterLocations(news, q);
        didYouMean(news, q);
        _oldComputeFiltered(olds, q);
        _oldDidYouMean(olds, q);
      }
    }
    final oldTimes = <int>[];
    final newTimes = <int>[];
    for (var i = 0; i < 5; i++) {
      oldTimes.add(time(() {
        for (final q in fuzzyQueries) {
          _oldComputeFiltered(olds, q);
          _oldDidYouMean(olds, q);
        }
      }));
      newTimes.add(time(() {
        for (final q in fuzzyQueries) {
          filterLocations(news, q);
          didYouMean(news, q);
        }
      }));
    }
    oldTimes.sort();
    newTimes.sort();
    final oldMedian = oldTimes[2], newMedian = newTimes[2];
    // ignore: avoid_print
    print('D1 fuzzy passes (5 queries x search + did-you-mean, median of 5): '
        'old ${oldMedian ~/ 1000} ms, new ${newMedian ~/ 1000} ms');
    expect(newMedian * 2, lessThan(oldMedian), reason: 'at least 2x faster');
  });
}

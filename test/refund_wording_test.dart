// The owner's refund-wording rule (P0-1 of the 2026-10-05 review fix list):
// refunds "usually take 5–7 business days". Never "within minutes", never a
// "full refund" / "fully refunded" / "in full" promise, never a guarantee.
// Scans every string literal in lib/ (generated files excluded).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<String> problemsIn(String text) {
  final out = <String>[];
  final t = text.toLowerCase();
  if (RegExp(r'fully refund|refunded in full|refund in full|full refund').hasMatch(t)) {
    out.add('promises a full refund');
  }
  if (t.contains('within minutes') && t.contains('refund')) out.add('"within minutes" for a refund');
  if (t.contains('guarantee') && t.contains('refund')) out.add('guarantees a refund');
  if (RegExp(r'5\s*(?:[-–]|to)\s*7\s+(?:business|working)\s+days').hasMatch(t) &&
      !RegExp(r'usually|typically').hasMatch(t)) {
    out.add('"5–7 business days" without "usually"');
  }
  return out;
}

Iterable<String> literals(String line) sync* {
  final trimmed = line.trimLeft();
  if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) return;
  final re = RegExp(r"'((?:[^'\\]|\\.)*)'" '|' r'"((?:[^"\\]|\\.)*)"');
  for (final m in re.allMatches(line)) {
    yield m.group(1) ?? m.group(2) ?? '';
  }
}

List<String> scan() {
  final offenders = <String>[];
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart') && !f.path.endsWith('.freezed.dart'));
  for (final f in files) {
    final lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      for (final lit in literals(lines[i])) {
        for (final why in problemsIn(lit)) {
          offenders.add('${f.path.replaceAll('\\', '/')}:${i + 1} $why: $lit');
        }
      }
    }
  }
  return offenders;
}

void main() {
  test('the checker: catches each banned form, accepts the house wording', () {
    expect(problemsIn('Your payment was fully refunded automatically.'), hasLength(1));
    expect(problemsIn('Refund will be processed within 5 to 7 working days.'), hasLength(1));
    expect(problemsIn('Refunds usually take 5–7 business days.'), isEmpty);
    expect(problemsIn('Rhododendron bloom in full swing'), isEmpty);
  });

  test('no string in the app breaks it', () {
    expect(scan(), isEmpty);
  });
}

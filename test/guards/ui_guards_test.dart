// Static guards over lib/ for touch and behaviour bugs found on a real phone
// (14 Oct 2026), so the same kind can't come back as the app grows.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<(String, List<String>)> _dartFiles() sync* {
  for (final e in Directory('lib').listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    if (e.path.contains('.freezed.') || e.path.endsWith('.g.dart')) continue;
    yield (e.path.replaceAll(r'\', '/'), e.readAsLinesSync());
  }
}

void main() {
  test('no tap area that is only a bare icon (use TapTarget: 48 dp, same drawing)', () {
    // Reviewed exceptions: the 5 rating stars (48 dp each would not fit the
    // popup) and a round button that already draws its own sized circle.
    const allowed = {
      'lib/widgets/rate_trek_popup.dart',
      'lib/screens/source_location_screen.dart',
    };
    final bareIcon = RegExp(r'child:\s*(const\s+)?Icon\(');
    final hits = <String>[];
    for (final (path, lines) in _dartFiles()) {
      if (allowed.contains(path)) continue;
      for (var i = 0; i < lines.length; i++) {
        if (!RegExp(r'\b(GestureDetector|InkWell)\(').hasMatch(lines[i])) continue;
        final window = lines.skip(i).take(6).join(' ');
        if (bareIcon.hasMatch(window)) hits.add('$path:${i + 1}');
      }
    }
    expect(hits, isEmpty, reason: 'Wrap these in TapTarget (lib/widgets/tap_target.dart)');
  });

  test('no button whose only action is a "coming soon" toast', () {
    final hits = <String>[];
    for (final (path, lines) in _dartFiles()) {
      if (path.endsWith('claims_screen.dart')) continue; // not reachable (scan E11)
      for (var i = 0; i < lines.length; i++) {
        final window = lines.skip(i).take(4).join(' ').toLowerCase();
        if (RegExp(r'on(tap|pressed):\s*\(\)\s*=>\s*(customsnackbar|appfeedback)').hasMatch(window) &&
            window.contains('coming soon')) {
          hits.add('$path:${i + 1}');
        }
      }
    }
    expect(hits, isEmpty, reason: 'Link the real screen, or hide the button until it exists');
  });

  test('never two Get.back() in a row (closes a screen the user did not leave)', () {
    final hits = <String>[];
    for (final (path, lines) in _dartFiles()) {
      for (var i = 0; i + 1 < lines.length; i++) {
        if (lines[i].trim() == 'Get.back();' && lines[i + 1].trim() == 'Get.back();') {
          hits.add('$path:${i + 1}');
        }
      }
    }
    expect(hits, isEmpty);
  });
}

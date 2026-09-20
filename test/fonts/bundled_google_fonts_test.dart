import 'dart:async';

import 'package:flutter/painting.dart' show FontWeight;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Real phones (OnePlus 8 Pro, vivo) reported
//   "Exception: Failed to load font with url: https://fonts.gstatic.com/s/a/b1e3f7ae….ttf"
// — that file is Saira Stencil One Regular, the splash/login headline font,
// downloaded from Google on first use and failing on weak connections.
// The three runtime-downloaded families are now bundled in assets/google_fonts/.
//
// These tests turn runtime fetching OFF, so the network fallback is impossible:
// a font that is not found in the bundled assets throws
//   "allowRuntimeFetching is false but font X was not found in the application assets".
// A bundled font loads silently; the control (an unbundled font) must throw, which
// proves the harness can actually detect a missing/renamed asset.

Future<List<Object>> _loadAndCollectErrors(void Function() requestFont) async {
  final errors = <Object>[];
  await runZonedGuarded(
    () async {
      requestFont();
      try {
        await GoogleFonts.pendingFonts();
      } catch (e) {
        errors.add(e);
      }
    },
    (e, _) => errors.add(e),
  );
  // Let any un-awaited font-load future finish and report to the zone handler.
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return errors;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => GoogleFonts.config.allowRuntimeFetching = true);

  test('Saira Stencil One (splash + login headline) loads from the bundle', () async {
    final errors = await _loadAndCollectErrors(() => GoogleFonts.sairaStencilOne());
    expect(errors, isEmpty);
  });

  test('Source Serif 4 Bold (dashboard, upcoming booking, payment success) loads from the bundle', () async {
    final errors = await _loadAndCollectErrors(
      () => GoogleFonts.sourceSerif4(fontWeight: FontWeight.bold),
    );
    expect(errors, isEmpty);
  });

  test('Playfair Display Bold (About Us) loads from the bundle', () async {
    final errors = await _loadAndCollectErrors(
      () => GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
    );
    expect(errors, isEmpty);
  });

  // MUST stay last: GoogleFonts keeps a process-wide list of pending font loads and
  // pendingFonts() awaits ALL of them, so a deliberately-failing font here would
  // poison every test that runs after it.
  test('control: a font that is NOT bundled throws when runtime fetching is off', () async {
    final errors = await _loadAndCollectErrors(() => GoogleFonts.lato());
    expect(errors, isNotEmpty, reason: 'the harness must be able to detect a missing bundled font');
    expect(errors.first.toString(), contains('was not found in the application assets'));
  });
}

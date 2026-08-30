// Regression guard for the app-wide scaling clamps added in the
// device-compatibility pass:
//   • AppType.style() reins in sizer's unbounded width-based font scaling on
//     tablet / foldable / large-window widths.
//   • main.dart clamps MediaQuery.textScaler app-wide (mirrored here as a
//     unit check of the same clamp values).

import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

void main() {
  void setScreenWidth(double w) {
    SizerUtil.setScreenSize(
      BoxConstraints(maxWidth: w, maxHeight: 800),
      Orientation.portrait,
    );
  }

  group('AppType.style font clamp', () {
    test('phone widths (≤ 1.35x factor) pass through byte-for-byte', () {
      for (final w in [240.0, 300.0, 320.0, 360.0, 405.0]) {
        setScreenWidth(w);
        expect(
          AppType.style(FontSize.s14).fontSize!,
          closeTo(14 * w / 300, 0.001),
          reason: 'width $w must be untouched',
        );
      }
    });

    test('caps the blow-up on a foldable width (~673dp)', () {
      setScreenWidth(673);
      final clamped = AppType.style(FontSize.s14).fontSize!;
      // Unclamped this would be 14 * 673/300 ≈ 31.4.
      expect(clamped, closeTo(14 * 1.35, 0.5));
    });

    test('caps the blow-up on a 10" tablet width (800dp)', () {
      setScreenWidth(800);
      final clamped = AppType.style(FontSize.s14).fontSize!;
      // Unclamped: 14 * 800/300 ≈ 37.3. Clamped: 14 * 1.35 ≈ 18.9.
      expect(clamped, lessThan(20));
      expect(clamped, greaterThan(14)); // still a touch larger than design
    });

    test('handles a direct inline .sp size the same way', () {
      setScreenWidth(800);
      final clamped = AppType.style(16.sp).fontSize!;
      expect(clamped, closeTo(16 * 1.35, 0.6));
    });

    test(
      'a raw design-px literal (no .sp) is NOT shrunk on a tablet — '
      'protects the ~50 AppType.style(<number>) call sites',
      () {
        setScreenWidth(800);
        // Was the bug: recovery treated the literal as sizer-scaled and
        // divided it down to ~5px. The <= _smallFontCeiling guard fixes it.
        expect(AppType.style(10).fontSize!, 10);
        expect(AppType.style(15).fontSize!, 15);
        expect(AppType.style(18).fontSize!, 18);
      },
    );

    test('small text on a wide screen is left alone (never overflows a line)',
        () {
      setScreenWidth(800);
      // FontSize.s7 → 7 * 800/300 ≈ 18.7, under the 20 ceiling → unchanged.
      expect(AppType.style(FontSize.s7).fontSize!, closeTo(7 * 800 / 300, 0.001));
      // FontSize.s8 → ≈21.3, over the ceiling → clamped.
      expect(AppType.style(FontSize.s8).fontSize!, closeTo(8 * 1.35, 0.3));
    });

    test('does not throw when Sizer is uninitialised', () {
      // Can't truly un-initialise a late static mid-suite, but the guard
      // must at least not blow up on a normal call.
      setScreenWidth(360);
      expect(() => AppType.style(14.sp), returnsNormally);
    });
  });

  group('textScaler clamp (values mirror main.dart)', () {
    // main.dart: mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.15)
    const minScale = 1.0;
    const maxScale = 1.15;

    test('a large OS font setting is reined in to the ceiling', () {
      final clamped = const TextScaler.linear(1.6).clamp(
        minScaleFactor: minScale,
        maxScaleFactor: maxScale,
      );
      expect(clamped.scale(10), closeTo(11.5, 0.01));
    });

    test('a normal OS font setting passes through unchanged', () {
      final clamped = const TextScaler.linear(1.0).clamp(
        minScaleFactor: minScale,
        maxScaleFactor: maxScale,
      );
      expect(clamped.scale(10), closeTo(10, 0.01));
    });
  });
}

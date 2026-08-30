// lib/theme/app_typography.dart
//
// The single Poppins style factory. Replaces AppTextStyles, AppText
// (screenutil — DELETED), AroboTheme.label and inline GoogleFonts.poppins.
// Sizer-backed via FontSize, matching the app's existing convention.

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/screen_constants.dart';
import 'app_tokens.dart';

class AppType {
  AppType._();

  // `sizer`'s `.sp` (which every FontSize.sX and every inline `N.sp` passed
  // here is built on) multiplies the design size by `screenWidth / 300` with
  // NO ceiling — so on a 10" tablet (800dp) FontSize.s14 resolves to ~37px
  // and on an unfolded foldable (~600dp) to ~28px, blowing dense layouts
  // apart. Phones (≈320–412dp → factor ≈1.07–1.37) are already fine.
  //
  // `_clampFont` only acts on genuinely large on-screen sizes on genuinely
  // wide viewports: it recovers the design px and re-applies the width
  // factor capped at `_maxWidthFactor`. Two guards keep it from doing harm:
  //   • it no-ops entirely unless the sizer factor is above the cap (so
  //     every phone is byte-for-byte unchanged), and
  //   • it leaves anything already ≤ `_smallFontCeiling` alone — that skips
  //     the ~50 `AppType.style(<raw number>)` call sites (dialogs, sheets,
  //     seasonal cards…) that pass an unscaled design px and must NOT be
  //     divided down, and small text can't overflow a line anyway.
  static const double _maxWidthFactor = 1.35;
  static const double _smallFontCeiling = 20.0;

  static double _clampFont(double size) {
    double rawFactor;
    try {
      rawFactor = SizerUtil.width / 300.0;
    } catch (_) {
      // Sizer not initialised (e.g. a widget test with no Sizer ancestor).
      return size;
    }
    if (rawFactor <= _maxWidthFactor) return size;
    if (size <= _smallFontCeiling) return size;
    final designPx = size / rawFactor;
    return designPx * _maxWidthFactor;
  }

  /// Public form of the same clamp, for the handful of text styles that
  /// aren't built through [style] — raw `TextStyle(fontSize: …)` and
  /// `GoogleFonts.x(fontSize: …)`. Pass the sizer-scaled value
  /// (`FontSize.sX` or `N.sp`); phones are unchanged, tablet/foldable are
  /// reined in. Do NOT wrap a widget's own `fontSize:` parameter
  /// (e.g. CommonButton) — those already route through [style] internally.
  static double clampFontSize(double sizerScaledSize) =>
      _clampFont(sizerScaledSize);

  static TextStyle style(
    double size, {
    FontWeight w = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: _clampFont(size),
    fontWeight: w,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
    decorationColor: decorationColor,
    fontStyle: fontStyle,
    shadows: shadows,
  );

  // ── Semantic ramp ──────────────────────────
  static TextStyle get h1 =>
      style(FontSize.s18, w: FontWeight.w800, letterSpacing: -0.3);
  static TextStyle get h2 => style(FontSize.s15, w: FontWeight.w700);
  static TextStyle get h3 => style(FontSize.s13, w: FontWeight.w700);
  static TextStyle get titleSm => style(FontSize.s11, w: FontWeight.w600);
  static TextStyle get body => style(FontSize.s11, height: 1.5);
  static TextStyle get bodySm =>
      style(FontSize.s10, color: AppColors.inkMid, height: 1.5);
  static TextStyle get caption => style(FontSize.s9, color: AppColors.inkMid);
  static TextStyle get micro => style(FontSize.s8, color: AppColors.inkLight);
  static TextStyle get overline => style(
    FontSize.s7,
    w: FontWeight.w600,
    color: AppColors.inkLight,
    letterSpacing: 1,
  );
  static TextStyle get button =>
      style(FontSize.s12, w: FontWeight.w700, color: Colors.white);
}

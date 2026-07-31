// lib/theme/app_typography.dart
//
// The single Poppins style factory. Replaces AppTextStyles, AppText
// (screenutil — DELETED), AroboTheme.label and inline GoogleFonts.poppins.
// Sizer-backed via FontSize, matching the app's existing convention.

import 'package:flutter/material.dart';
import '../utils/screen_constants.dart';
import 'app_tokens.dart';

class AppType {
  AppType._();

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
    fontSize: size,
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

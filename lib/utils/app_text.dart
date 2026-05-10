import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography system for consistent text styling across the app.
/// All font sizes use .sp extension for responsive scaling.
class AppText {

  /// Default font family
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: size.sp,
      fontWeight: weight,
      height: height,
    );
  }

  // --------------------------------------------------
  // HEADINGS
  // --------------------------------------------------

  static TextStyle heading1 = _base(size: 36, weight: FontWeight.w900);
  static TextStyle heading2 = _base(size: 30, weight: FontWeight.w900);
  static TextStyle heading3 = _base(size: 24, weight: FontWeight.w700);
  static TextStyle heading4 = _base(size: 20, weight: FontWeight.w700);

  // --------------------------------------------------
  // SUB HEADINGS
  // --------------------------------------------------

  static TextStyle subHeading1 = _base(size: 18, weight: FontWeight.w600);
  static TextStyle subHeading2 = _base(size: 16, weight: FontWeight.w600);
  static TextStyle subHeading3 = _base(size: 14, weight: FontWeight.w600);

  /// Alias used by screens
  static TextStyle subHeading = subHeading2;

  // --------------------------------------------------
  // BODY
  // --------------------------------------------------

  static TextStyle body1 = _base(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle body2 = _base(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle body3 = _base(size: 13, weight: FontWeight.w400);

  /// Alias used by screens
  static TextStyle body = body2;

  // --------------------------------------------------
  // CAPTIONS
  // --------------------------------------------------

  static TextStyle caption1 = _base(size: 12, weight: FontWeight.w400);
  static TextStyle caption2 = _base(size: 11, weight: FontWeight.w400);
  static TextStyle caption3 = _base(size: 10, weight: FontWeight.w400);

  /// Alias used by screens
  static TextStyle caption = caption1;

  // --------------------------------------------------
  // SMALL TEXT
  // --------------------------------------------------

  static TextStyle small = _base(size: 9, weight: FontWeight.w400);
  static TextStyle tiny = _base(size: 8, weight: FontWeight.w400);

  // --------------------------------------------------
  // BUTTONS
  // --------------------------------------------------

  static TextStyle buttonLarge = _base(size: 16, weight: FontWeight.w600);
  static TextStyle buttonMedium = _base(size: 14, weight: FontWeight.w600);
  static TextStyle buttonSmall = _base(size: 12, weight: FontWeight.w600);

  // --------------------------------------------------
  // LABELS
  // --------------------------------------------------

  static TextStyle label = _base(size: 12, weight: FontWeight.w500);
  static TextStyle labelSmall = _base(size: 10, weight: FontWeight.w500);
}

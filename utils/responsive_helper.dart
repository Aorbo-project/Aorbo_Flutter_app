import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Helper class for creating responsive UI spacing, padding and radius.
class ResponsiveHelper {

  // ---------- Vertical Spacing ----------

  static SizedBox vSpace(double height) {
    return SizedBox(height: height.h);
  }

  static SizedBox get vSpace3 => SizedBox(height: 3.h);
  static SizedBox get vSpace4 => SizedBox(height: 4.h);
  static SizedBox get vSpace5 => SizedBox(height: 5.h);
  static SizedBox get vSpace8 => SizedBox(height: 8.h);
  static SizedBox get vSpace10 => SizedBox(height: 10.h);
  static SizedBox get vSpace12 => SizedBox(height: 12.h);
  static SizedBox get vSpace15 => SizedBox(height: 15.h);
  static SizedBox get vSpace16 => SizedBox(height: 16.h);
  static SizedBox get vSpace20 => SizedBox(height: 20.h);
  static SizedBox get vSpace21 => SizedBox(height: 21.h);
  static SizedBox get vSpace24 => SizedBox(height: 24.h);
  static SizedBox get vSpace25 => SizedBox(height: 25.h);
  static SizedBox get vSpace30 => SizedBox(height: 30.h);
  static SizedBox get vSpace34 => SizedBox(height: 34.h);
  static SizedBox get vSpace39 => SizedBox(height: 39.h);

  // ---------- Horizontal Spacing ----------

  static SizedBox hSpace(double width) {
    return SizedBox(width: width.w);
  }

  static SizedBox get hSpace4 => SizedBox(width: 4.w);
  static SizedBox get hSpace6 => SizedBox(width: 6.w);
  static SizedBox get hSpace7 => SizedBox(width: 7.w);
  static SizedBox get hSpace8 => SizedBox(width: 8.w);
  static SizedBox get hSpace10 => SizedBox(width: 10.w);
  static SizedBox get hSpace12 => SizedBox(width: 12.w);
  static SizedBox get hSpace20 => SizedBox(width: 20.w);
  static SizedBox get hSpace21 => SizedBox(width: 21.w);
  static SizedBox get hSpace24 => SizedBox(width: 24.w);
  static SizedBox get hSpace85 => SizedBox(width: 85.w);

  // ---------- Border Radius ----------

  static BorderRadius get radius4 => BorderRadius.circular(4.sp);
  static BorderRadius get radius5 => BorderRadius.circular(5.sp);
  static BorderRadius get radius8 => BorderRadius.circular(8.sp);
  static BorderRadius get radius10 => BorderRadius.circular(10.sp);
  static BorderRadius get radius12 => BorderRadius.circular(12.sp);
  static BorderRadius get radius15 => BorderRadius.circular(15.sp);
  static BorderRadius get radius18 => BorderRadius.circular(18.sp);
  static BorderRadius get radius20 => BorderRadius.circular(20.sp);
  static BorderRadius get radius45 => BorderRadius.circular(45.sp);

  // ---------- Padding ----------

  static EdgeInsets get padding4 => EdgeInsets.all(4.w);
  static EdgeInsets get padding8 => EdgeInsets.all(8.w);
  static EdgeInsets get padding10 => EdgeInsets.all(10.w);
  static EdgeInsets get padding12 => EdgeInsets.all(12.w);
  static EdgeInsets get padding16 => EdgeInsets.all(16.w);
  static EdgeInsets get padding20 => EdgeInsets.all(20.w);
  static EdgeInsets get padding30 => EdgeInsets.all(30.w);

  // ---------- Symmetric Padding ----------

  static EdgeInsets paddingSymmetricH(double horizontal) {
    return EdgeInsets.symmetric(horizontal: horizontal.w);
  }

  static EdgeInsets paddingSymmetricV(double vertical) {
    return EdgeInsets.symmetric(vertical: vertical.h);
  }

  static EdgeInsets paddingSymmetric({double h = 0, double v = 0}) {
    return EdgeInsets.symmetric(horizontal: h.w, vertical: v.h);
  }

  // ---------- Icon Sizes ----------

  static double get iconXSmall => 12.sp;
  static double get iconSmall => 16.sp;
  static double get iconMedium => 24.sp;
  static double get iconLarge => 32.sp;
  static double get iconXLarge => 48.sp;
}

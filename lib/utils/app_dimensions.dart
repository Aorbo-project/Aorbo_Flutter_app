import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Centralized dimension constants for the Aorbo Treks app.
/// All values are extracted from the finalized OLD codebase (arobo_app).
/// Uses Sizer (.w for width%, .h for height%, .sp for font size).
///
/// Usage:
///   SizedBox(height: AppDimensions.spacingM)
///   CommonButton(height: AppDimensions.buttonHeight)
///   Text('...', style: TextStyle(fontSize: AppDimensions.fontBody))
class AppDimensions {
  AppDimensions._();

  // ─── SPLASH SCREEN ───────────────────────────────────────────────────
  /// Logo initial width during splash animation (before shrink)
  static double get splashLogoInitialWidth => 70.w;

  /// Logo initial height during splash animation (before shrink)
  static double get splashLogoInitialHeight => 50.h;

  /// Logo final (collapsed) width after splash animation
  static double get splashLogoFinalWidth => 46.w;

  /// Logo final (collapsed) height after splash animation
  static double get splashLogoFinalHeight => 10.h;

  // ─── AUTHENTICATION SCREENS ──────────────────────────────────────────
  /// Top vertical spacing before heading text on Login / Auth screens
  static double get authTopSpacing => 10.h;

  /// Horizontal margin for the form container on Auth screens
  static double get authFormHorizontalMargin => 8.w;

  /// Height of phone number input field
  static double get phoneInputHeight => 6.h;

  /// Border radius of phone number input field
  static double get phoneInputBorderRadius => 4.h;

  /// Horizontal padding inside phone input field
  static double get phoneInputHorizontalPadding => 4.w;

  /// Spacing between +91 prefix and text field
  static double get phoneInputPrefixSpacing => 2.w;

  /// Spacing below the phone input field (before button)
  static double get phoneInputBottomSpacing => 3.h;

  /// Spacing above heading text in OTP view / auth forms
  static double get otpTopSpacing => 5.h;

  /// Spacing between header row and subheading in OTP view
  static double get otpHeaderBottomSpacing => 5.h;

  /// OTP heading left padding
  static double get otpHeadingLeftPadding => 4.w;

  /// Spacing below OTP subheading
  static double get otpSubheadingBottomSpacing => 4.h;

  /// OTP pin cell width
  static double get otpPinWidth => 25.sp;

  /// OTP pin cell height
  static double get otpPinHeight => 40.sp;

  /// OTP pin cell border radius
  static double get otpPinBorderRadius => 10.sp;

  /// Separator width between OTP pin cells
  static double get otpPinSeparatorWidth => 4.5.w;

  /// Spacing below OTP pin row
  static double get otpPinBottomSpacing => 4.h;

  /// Back arrow icon spacing (OTP header back button)
  static double get otpBackIconSpacing => 5.w;

  // ─── BUTTONS ─────────────────────────────────────────────────────────
  /// Standard full-width button height
  static double get buttonHeight => 6.h;

  /// Button border radius
  static double get buttonBorderRadius => 4.h;

  /// Button default width (non-full-width)
  static double get buttonDefaultWidth => 40.w;

  /// Horizontal padding inside button (for icon spacing)
  static double get buttonIconSpacingH => 1.w;

  // ─── TREK CARD ───────────────────────────────────────────────────────
  /// Trek card total width
  static double get trekCardWidth => 92.w;

  /// Trek card height (no discount/badge)
  static double get trekCardHeight => 22.h;

  /// Trek card height (with discount or badge)
  static double get trekCardHeightWithBadge => 23.h;

  /// Trek card horizontal margin
  static double get trekCardHorizontalMargin => 3.w;

  /// Trek card border radius
  static double get trekCardBorderRadius => 2.h;

  /// Trek card internal padding (left, top, right, bottom)
  static EdgeInsets get trekCardPadding =>
      EdgeInsets.fromLTRB(4.w, 1.5.h, 3.w, 1.4.h);

  /// Trek card logo icon size
  static double get trekCardLogoSize => 12.w;

  /// Trek card spacing between logo and text
  static double get trekCardLogoTextSpacing => 3.w;

  /// Trek card title font size → FontSize.s11
  static double get trekCardTitleSpacing => 0.8.h;

  /// Trek card discount badge padding (horizontal)
  static double get trekCardBadgePaddingH => 2.w;

  /// Trek card discount badge padding (vertical)
  static double get trekCardBadgePaddingV => 0.6.h;

  /// Trek card badge border radius
  static double get trekCardBadgeBorderRadius => 0.8.h;

  /// Trek card rating pill horizontal padding
  static double get trekCardRatingPaddingLeft => 0.8.w;
  static double get trekCardRatingPaddingRight => 2.w;
  static double get trekCardRatingPaddingTop => 0.25.h;
  static double get trekCardRatingPaddingBottom => 0.4.h;

  /// Trek card rating pill border radius
  static double get trekCardRatingBorderRadius => 1.5.w;

  /// Trek card rating star icon size
  static double get trekCardRatingStarSize => 3.8.w;

  /// Trek card rating pill icon spacing
  static double get trekCardRatingIconSpacing => 0.5.w;

  /// Trek card share icon size
  static double get trekCardShareIconSize => 4.w;

  /// Trek card share icon-text spacing
  static double get trekCardShareSpacing => 1.5.w;

  // ─── BOTTOM NAVIGATION BAR ───────────────────────────────────────────
  /// Bottom nav bar background color is CommonColors.whiteColor (no height override; uses system default ~56dp)

  // ─── COMMON SPACING ──────────────────────────────────────────────────
  /// Extra-small vertical spacing
  static double get spacingXS => 0.5.h;

  /// Small vertical spacing
  static double get spacingS => 1.h;

  /// Medium vertical spacing
  static double get spacingM => 3.h;

  /// Large vertical spacing
  static double get spacingL => 4.h;

  /// Extra-large vertical spacing
  static double get spacingXL => 5.h;

  /// Extra-small horizontal spacing
  static double get hSpacingXS => 0.5.w;

  /// Small horizontal spacing
  static double get hSpacingS => 1.w;

  /// Medium horizontal spacing
  static double get hSpacingM => 3.w;

  /// Large horizontal spacing
  static double get hSpacingL => 4.w;

  // ─── SCREEN / FORM PADDING ───────────────────────────────────────────
  /// Standard horizontal screen padding
  static double get screenHorizontalPadding => 4.w;

  /// Standard vertical screen padding
  static double get screenVerticalPadding => 2.h;

  // ─── ICON SIZES ─────────────────────────────────────────────────────
  /// Small icon (inline text actions)
  static double get iconSizeS => 3.8.w;

  /// Medium icon (standard action icons)
  static double get iconSizeM => 4.w;

  /// Large icon (primary navigation icons)
  static double get iconSizeL => 6.w;

  // ─── SHADOWS ─────────────────────────────────────────────────────────
  /// Standard box shadow blur radius (for cards, input fields)
  static double get shadowBlurRadius => 1.h;

  /// Standard box shadow Y offset (for cards, input fields)
  static double get shadowOffsetY => 0.5.h;

  /// Card box shadow blur
  static double cardBoxShadowBlur = 6;

  /// Card box shadow spread
  static double cardBoxShadowSpread = 2;
}

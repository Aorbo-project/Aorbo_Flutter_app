import 'package:flutter/material.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';

/// Centralized text style constants for the Aorbo Treks app.
/// All font size values use FontSize.sXX (Sizer .sp) from screen_constants.dart.
/// Extracted from the finalized OLD codebase (arobo_app).
///
/// Usage:
///   Text('Hello', style: AppTextStyles.heading)
///   Text('Body', style: AppTextStyles.bodyMedium)
class AppTextStyles {
  AppTextStyles._();

  // ─── HEADINGS ────────────────────────────────────────────────────────
  /// Large screen heading (splash login heading: 24.sp, SairaStencilOne)
  static TextStyle splashHeading = TextStyle(
    fontSize: FontSize.s24,
    fontWeight: FontWeight.w600,
    fontFamily: 'SairaStencilOne',
    color: CommonColors.blackColor,
  );

  /// Auth screen heading / section title (19.sp Poppins Bold)
  static TextStyle authHeading = TextStyle(
    fontSize: FontSize.s19,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
  );

  /// Auth heading secondary lines (19.sp Poppins SemiBold white)
  static TextStyle authHeadingSecondary = TextStyle(
    fontSize: FontSize.s19,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: CommonColors.whiteColor,
  );

  /// Auth heading accent / highlight (19.sp Poppins Bold yellow)
  static TextStyle authHeadingAccent = TextStyle(
    fontSize: FontSize.s19,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: CommonColors.appYellowColor,
  );

  // ─── SECTION TITLES & LABELS ─────────────────────────────────────────
  /// OTP / form section title (14.sp Poppins SemiBold)
  static TextStyle sectionTitle = TextStyle(
    fontSize: FontSize.s14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  /// OTP subtitle / sub-label (12.sp Poppins Medium)
  static TextStyle sectionSubtitle = TextStyle(
    fontSize: FontSize.s12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
  );

  // ─── BODY TEXT ───────────────────────────────────────────────────────
  /// Body large (14.sp Poppins Regular)
  static TextStyle bodyLarge = TextStyle(
    fontSize: FontSize.s14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: CommonColors.textColor,
  );

  /// Body medium (12.sp Poppins Regular)
  static TextStyle bodyMedium = TextStyle(
    fontSize: FontSize.s12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: CommonColors.textColor,
  );

  /// Body small (10.sp Poppins Regular)
  static TextStyle bodySmall = TextStyle(
    fontSize: FontSize.s10,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: CommonColors.textColor,
  );

  // ─── CAPTIONS & HINTS ────────────────────────────────────────────────
  /// Caption / hint text (9.sp Poppins Regular)
  static TextStyle caption = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.greyColor,
  );

  /// Inline links & disclaimer text (9.sp Poppins Medium white)
  static TextStyle disclaimerText = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.whiteColor,
  );

  /// Link / accent disclaimer (9.sp Poppins ExtraBold yellow)
  static TextStyle disclaimerLink = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins',
    color: CommonColors.appYellowColor,
  );

  // ─── BUTTONS ─────────────────────────────────────────────────────────
  /// Standard button label (14.sp Poppins ExtraBold)
  static TextStyle buttonText = TextStyle(
    fontSize: FontSize.s14,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins',
    color: CommonColors.searchbtntext,
  );

  // ─── TREK CARD ───────────────────────────────────────────────────────
  /// Trek card title (11.sp Poppins SemiBold)
  static TextStyle trekCardTitle = TextStyle(
    fontSize: FontSize.s11,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
  );

  /// Trek card vendor name (9.sp Poppins Regular grey)
  static TextStyle trekCardVendor = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: CommonColors.grey_AEAEAE,
  );

  /// Trek card badge label (7.sp Poppins SemiBold)
  static TextStyle trekCardBadge = TextStyle(
    fontSize: FontSize.s7,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
    letterSpacing: 1,
  );

  /// Trek card price (14.sp Roboto ExtraBold)
  static TextStyle trekCardPrice = TextStyle(
    fontSize: FontSize.s14,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    color: CommonColors.blackColor,
  );

  /// Trek card price discounted (14.sp Roboto ExtraBold green)
  static TextStyle trekCardPriceDiscounted = TextStyle(
    fontSize: FontSize.s14,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    color: CommonColors.softGreen3,
  );

  /// Trek card original price strikethrough (8.sp Roboto regular)
  static TextStyle trekCardOriginalPrice = TextStyle(
    fontSize: FontSize.s8,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
    decoration: TextDecoration.lineThrough,
  );

  /// Trek card sub-label (10.sp Poppins SemiBold)
  static TextStyle trekCardSubLabel = TextStyle(
    fontSize: FontSize.s10,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
  );

  /// Trek card sub-value (9.sp Poppins Medium muted)
  static TextStyle trekCardSubValue = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );

  /// Trek card rating text (11.sp Poppins Medium white)
  static TextStyle trekCardRating = TextStyle(
    fontSize: FontSize.s11,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.whiteColor,
  );

  /// Trek card action link (9.sp Poppins Medium blue)
  static TextStyle trekCardActionLink = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.blueColor,
  );

  // ─── INPUT FIELDS ────────────────────────────────────────────────────
  /// Phone input prefix +91 (11.sp Poppins Medium) — login screen
  static TextStyle phoneInputPrefix = TextStyle(
    fontSize: FontSize.s11,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );

  /// Phone input field text (12.sp) — login_screen.dart
  static TextStyle phoneInputText = TextStyle(
    fontSize: FontSize.s12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );

  /// OTP timer countdown (14.sp Poppins Medium black, letterSpacing 0.5w)
  static TextStyle otpTimer = TextStyle(
    fontSize: FontSize.s14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
  );

  /// OTP resend link (9.sp blue underlined)
  static TextStyle otpResendLink = TextStyle(
    fontSize: FontSize.s9,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: CommonColors.bluebac,
    decoration: TextDecoration.underline,
  );

  /// OTP pin text inside cell (16.sp Poppins Bold)
  static TextStyle otpPinText = TextStyle(
    fontSize: FontSize.s16,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: CommonColors.blackColor,
  );
}

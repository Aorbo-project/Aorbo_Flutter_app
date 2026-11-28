import 'package:flutter/material.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/theme/app_typography.dart';

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
  static TextStyle get splashHeading => TextStyle(
    fontSize: FontSize.s24,
    fontWeight: FontWeight.w600,
    fontFamily: 'SairaStencilOne',
    color: CommonColors.blackColor,
  );

  /// Auth screen heading / section title (19.sp Poppins Bold)
  static TextStyle get authHeading => AppType.style(FontSize.s19, w: FontWeight.w700, color: CommonColors.blackColor);

  /// Auth heading secondary lines (19.sp Poppins SemiBold white)
  static TextStyle get authHeadingSecondary => AppType.style(FontSize.s19, w: FontWeight.w600, color: CommonColors.whiteColor);

  /// Auth heading accent / highlight (19.sp Poppins Bold yellow)
  static TextStyle get authHeadingAccent => AppType.style(FontSize.s19, w: FontWeight.w700, color: CommonColors.appYellowColor);

  // ─── SECTION TITLES & LABELS ─────────────────────────────────────────
  /// OTP / form section title (14.sp Poppins SemiBold)
  static TextStyle get sectionTitle => AppType.style(FontSize.s14, w: FontWeight.w600);

  /// OTP subtitle / sub-label (12.sp Poppins Medium)
  static TextStyle get sectionSubtitle => AppType.style(FontSize.s12, w: FontWeight.w500, color: CommonColors.blackColor);

  // ─── BODY TEXT ───────────────────────────────────────────────────────
  /// Body large (14.sp Poppins Regular)
  static TextStyle get bodyLarge => AppType.style(FontSize.s14, w: FontWeight.w400, color: CommonColors.textColor);

  /// Body medium (12.sp Poppins Regular)
  static TextStyle get bodyMedium => AppType.style(FontSize.s12, w: FontWeight.w400, color: CommonColors.textColor);

  /// Body small (10.sp Poppins Regular)
  static TextStyle get bodySmall => AppType.style(FontSize.s10, w: FontWeight.w400, color: CommonColors.textColor);

  // ─── CAPTIONS & HINTS ────────────────────────────────────────────────
  /// Caption / hint text (9.sp Poppins Regular)
  static TextStyle get caption => AppType.style(FontSize.s9, w: FontWeight.w500, color: CommonColors.greyColor);

  /// Inline links & disclaimer text (9.sp Poppins Medium white)
  static TextStyle get disclaimerText => AppType.style(FontSize.s9, w: FontWeight.w500, color: CommonColors.whiteColor);

  /// Link / accent disclaimer (9.sp Poppins ExtraBold yellow)
  static TextStyle get disclaimerLink => AppType.style(FontSize.s9, w: FontWeight.w800, color: CommonColors.appYellowColor);

  // ─── BUTTONS ─────────────────────────────────────────────────────────
  /// Standard button label (14.sp Poppins ExtraBold)
  static TextStyle get buttonText => AppType.style(FontSize.s14, w: FontWeight.w800, color: CommonColors.searchbtntext);

  // ─── TREK CARD ───────────────────────────────────────────────────────
  /// Trek card title (11.sp Poppins SemiBold)
  static TextStyle get trekCardTitle => AppType.style(FontSize.s11, w: FontWeight.w600, color: CommonColors.blackColor);

  /// Trek card vendor name (9.sp Poppins Regular grey)
  static TextStyle get trekCardVendor => AppType.style(FontSize.s9, w: FontWeight.w400, color: CommonColors.grey_AEAEAE);

  /// Trek card badge label (7.sp Poppins SemiBold)
  static TextStyle get trekCardBadge => AppType.style(FontSize.s7, w: FontWeight.w600, color: CommonColors.blackColor, letterSpacing: 1);

  /// Trek card price (14.sp Roboto ExtraBold)
  static TextStyle get trekCardPrice => AppType.style(FontSize.s14, w: FontWeight.w800, color: CommonColors.blackColor);

  /// Trek card price discounted (14.sp Roboto ExtraBold green)
  static TextStyle get trekCardPriceDiscounted => AppType.style(FontSize.s14, w: FontWeight.w800, color: CommonColors.softGreen3);

  /// Trek card original price strikethrough (8.sp Roboto regular)
  static TextStyle get trekCardOriginalPrice => AppType.style(FontSize.s8, w: FontWeight.w400, decoration: TextDecoration.lineThrough);

  /// Trek card sub-label (10.sp Poppins SemiBold)
  static TextStyle get trekCardSubLabel => AppType.style(FontSize.s10, w: FontWeight.w600, color: CommonColors.blackColor);

  /// Trek card sub-value (9.sp Poppins Medium muted)
  static TextStyle get trekCardSubValue => AppType.style(FontSize.s9, w: FontWeight.w500);

  /// Trek card rating text (11.sp Poppins Medium white)
  static TextStyle get trekCardRating => AppType.style(FontSize.s11, w: FontWeight.w500, color: CommonColors.whiteColor);

  /// Trek card action link (9.sp Poppins Medium blue)
  static TextStyle get trekCardActionLink => AppType.style(FontSize.s9, w: FontWeight.w500, color: CommonColors.blueColor);

  // ─── INPUT FIELDS ────────────────────────────────────────────────────
  /// Phone input prefix +91 (11.sp Poppins Medium) — login screen
  static TextStyle get phoneInputPrefix => AppType.style(FontSize.s11, w: FontWeight.w500);

  /// Phone input field text (12.sp) — login_screen.dart
  static TextStyle get phoneInputText => AppType.style(FontSize.s12, w: FontWeight.w400);

  /// OTP timer countdown (14.sp Poppins Medium black, letterSpacing 0.5w)
  static TextStyle get otpTimer => AppType.style(FontSize.s14, w: FontWeight.w500, color: CommonColors.blackColor);

  /// OTP resend link (9.sp blue underlined)
  static TextStyle get otpResendLink => AppType.style(FontSize.s9, w: FontWeight.w500, color: CommonColors.bluebac, decoration: TextDecoration.underline);

  /// OTP pin text inside cell (16.sp Poppins Bold)
  static TextStyle get otpPinText => AppType.style(FontSize.s16, w: FontWeight.w700, color: CommonColors.blackColor);
}

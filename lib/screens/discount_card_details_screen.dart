// DiscountCardDetailsScreen.dart

import 'package:arobo_app/models/discount_card_model.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../utils/ist_date_utils.dart';

/// Coupon detail screen. Rebuilt to extend the same gradient-hero language
/// as CouponGradientCard (utils/coupon_gradient_card.dart) instead of a
/// separate flat banner + hard-shadowed white boxes — the hero here is
/// just a bigger version of the shelf card, and every section below is
/// tied to the coupon's own accent color instead of a hardcoded blue.
///
/// Every section is optional and independently guarded, since coupons
/// vary in how much content they carry — a short flat-off coupon might
/// only have a description, while a campaign coupon has all four
/// sections. "How to Apply" and T&C render as real structured lists
/// (numbered steps, bolded labels) regardless of whether the admin typed
/// manual numbering into the raw text — so formatting never depends on
/// how carefully that text was authored.
class DiscountCardDetailsScreen extends StatelessWidget {
  final DiscountCardModel discountCard;

  const DiscountCardDetailsScreen({
    super.key,
    required this.discountCard,
  });

  @override
  Widget build(BuildContext context) {
    final colors = (discountCard.gradient == null || discountCard.gradient!.isEmpty)
        ? ['#0F7B6C', '#1AA090']
        : discountCard.gradient!;
    final startColor = AppTheme.hexToColor(colors.first);
    final endColor = AppTheme.hexToColor(colors.last);
    final accent = startColor;
    final heroTextColor = AppTheme.hexToColor(discountCard.textColour);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: heroTextColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Offer details',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w600,
            color: heroTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context, startColor, endColor, heroTextColor),

            Transform.translate(
              // Content sheet overlaps the hero's bottom edge slightly,
              // so the transition reads as one continuous surface rather
              // than two stacked blocks.
              offset: const Offset(0, -1),
              child: Container(
                width: 100.w,
                padding: EdgeInsets.fromLTRB(4.w, 2.6.h, 4.w, 4.h),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F6F5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (discountCard.detailedDescription?.isNotEmpty ?? false)
                      _buildParagraphSection(
                        accent: accent,
                        title: 'About this offer',
                        content: discountCard.detailedDescription!,
                      ),

                    if (discountCard.howToApply?.isNotEmpty ?? false)
                      _buildStepsSection(
                        accent: accent,
                        title: 'How to apply',
                        content: discountCard.howToApply!,
                      ),

                    if (discountCard.termsAndConditions?.isNotEmpty ?? false)
                      _buildTermsSection(
                        accent: accent,
                        title: 'Terms & conditions',
                        items: discountCard.termsAndConditions!,
                      ),

                    if (discountCard.validUntil?.isNotEmpty ?? false)
                      _buildValiditySection(
                        accent: accent,
                        validFrom: discountCard.validFrom,
                        validUntil: discountCard.validUntil!,
                        isLast: true,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    Color startColor,
    Color endColor,
    Color textColor,
  ) {
    // extendBodyBehindAppBar means the body starts at y=0, behind both the
    // status bar AND the AppBar itself — the previous version only
    // accounted for the status bar (viewPadding.top), so the AppBar's own
    // title/icon row was overlapping this hero's title underneath it.
    final topInset = MediaQuery.of(context).viewPadding.top + kToolbarHeight;

    return Container(
      width: 100.w,
      padding: EdgeInsets.fromLTRB(5.w, topInset + 2.5.h, 5.w, 3.5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: Stack(
        children: [
          // Soft radial highlight — same depth cue as the shelf card and
          // KnowMoreCard, so the hero reads as part of the same system.
          Positioned(
            right: -12.w,
            top: -8.h,
            child: Container(
              width: 55.w,
              height: 55.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discountCard.title,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.15,
                      ),
                    ),
                    if (discountCard.subtitle.isNotEmpty) ...[
                      SizedBox(height: 0.7.h),
                      Text(
                        discountCard.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s9,
                          color: textColor.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                    SizedBox(height: 1.8.h),
                    // offerAmount is a complete, pre-composed headline
                    // ("FLAT ₹200 OFF", "20% OFF") built by the caller —
                    // same convention as CouponGradientCard.headline. This
                    // used to hardcode "upto ₹{amount} off*", which only
                    // made sense for flat discounts and produced garbage
                    // like "₹20% off off*" for percentage-type coupons.
                    Text(
                      discountCard.offerAmount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: discountCard.code));
                        Get.snackbar(
                          'Copied!',
                          'Coupon code copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          margin: EdgeInsets.all(2.h),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.1.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              discountCard.code,
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: startColor,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(Icons.copy_rounded, size: 15, color: startColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (discountCard.imagePath.isNotEmpty) ...[
                SizedBox(width: 3.w),
                CustomNetworkImage(
                  imageUrl: discountCard.imagePath,
                  height: discountCard.imageHeight ?? 12.h,
                  width: 28.w,
                  fit: BoxFit.contain,
                  hasTransparentBackground: true,
                  borderRadius: 0,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionShell({
    required Color accent,
    required String title,
    required Widget child,
    bool isLast = false,
  }) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 1.8.h),
      padding: EdgeInsets.all(2.2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          SizedBox(height: 1.3.h),
          child,
        ],
      ),
    );
  }

  Widget _buildParagraphSection({
    required Color accent,
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return _buildSectionShell(
      accent: accent,
      title: title,
      isLast: isLast,
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: FontSize.s10,
          height: 1.55,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildValiditySection({
    required Color accent,
    String? validFrom,
    required String validUntil,
    bool isLast = false,
  }) {
    String? formatOrNull(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return ISTDateUtils.toIST(raw) != null
          ? ISTDateUtils.formatDateTime(raw)
          : null;
    }

    final startDate = formatOrNull(validFrom);
    final endDate = formatOrNull(validUntil);

    return _buildSectionShell(
      accent: accent,
      title: 'Coupon validity',
      isLast: isLast,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only shown when a start date is actually available — an offer
          // with no known start still shows its end date on its own rather
          // than rendering a blank/broken "Starts:" row.
          if (startDate != null) ...[
            _buildValidityRow(
              accent: accent,
              icon: Icons.play_circle_outline_rounded,
              label: 'Starts',
              value: startDate,
            ),
            SizedBox(height: 1.h),
          ],
          _buildValidityRow(
            accent: accent,
            icon: Icons.event_busy_rounded,
            label: 'Ends',
            value: endDate ?? 'Check T&C for validity',
          ),
        ],
      ),
    );
  }

  Widget _buildValidityRow({
    required Color accent,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: accent),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s10,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: FontSize.s10,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Splits on newlines and numbers each non-empty line — works whether the
  /// admin wrote plain steps or already prefixed them with "1.", since any
  /// leading digit-dot prefix is stripped before re-numbering. A single-line
  /// value (no newlines) just renders as one plain paragraph instead of a
  /// list of one, so short content doesn't look like a broken list.
  Widget _buildStepsSection({
    required Color accent,
    required String title,
    required String content,
  }) {
    final rawLines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''))
        .toList();

    if (rawLines.length <= 1) {
      return _buildParagraphSection(accent: accent, title: title, content: content.trim());
    }

    return _buildSectionShell(
      accent: accent,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rawLines.length, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == rawLines.length - 1 ? 0 : 1.1.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s8,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Text(
                    rawLines[i],
                    style: GoogleFonts.poppins(
                      fontSize: FontSize.s10,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Each item may optionally lead with a "Label:" prefix (e.g.
  /// "Eligibility: Offer valid only for first-time bookings.") — when
  /// present, the label is bolded; when absent, the whole line just reads
  /// as a plain bullet, so this works whether or not the admin structured
  /// their T&C text that way.
  Widget _buildTermsSection({
    required Color accent,
    required String title,
    required List<String> items,
  }) {
    return _buildSectionShell(
      accent: accent,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((term) {
          final match = RegExp(r'^([A-Za-z][A-Za-z \-]{2,30}):\s*(.+)$').firstMatch(term);
          return Padding(
            padding: EdgeInsets.only(bottom: 1.1.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: EdgeInsets.only(top: 0.9.h, right: 2.5.w),
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                Expanded(
                  child: match != null
                      ? RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: '${match.group(1)}: ',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: match.group(2)),
                            ],
                          ),
                        )
                      : Text(
                          term,
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

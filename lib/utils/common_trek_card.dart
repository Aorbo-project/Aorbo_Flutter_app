import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../freezed_models/treks/treks_model_data.dart';

class CommonTrekCard extends StatelessWidget {
  final TrekData? trek;
  final VoidCallback? onTap;
  final bool showShare;
  final VoidCallback? onShareTap;
  final VoidCallback? onViewItineraryTap;

  const CommonTrekCard({
    super.key,
    required this.trek,
    this.onTap,
    this.showShare = false,
    this.onShareTap,
    this.onViewItineraryTap,
  });

  LinearGradient getRatingColor(double rating) {
    if (rating >= 3.0 && rating <= 3.8) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD300), Color(0xFFFFD300)],
      );
    } else if (rating < 3.0) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF6B3A), Color(0xFFFF6B3A)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF19FA00), Color(0xFF4EE53D)],
    );
  }

  Color _parseBadgeColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return Colors.transparent;
    }
    if (colorHex.startsWith('#')) {
      try {
        // Add 'FF' as alpha if only RGB is provided
        String hex = colorHex.substring(1);
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        return Colors.transparent;
      }
    }
    return Colors.transparent; // Default fallback
  }

  // Method to get the current price (already discounted from API)
  String _calculateDiscountedPrice() {
    // The trek.price already contains the discounted price from the API
    // We don't need to apply discount calculation again here
    return trek?.price?.replaceAll(',', '') ?? '0.00';
  }

  // Method to get original price for strikethrough (calculate from discounted price)
  String _getOriginalPrice() {
    if (trek?.hasDiscount != true || trek?.discountText == null) {
      return trek?.price?.replaceAll(',', '') ?? '0.00';
    }

    double discountedPrice =
        double.tryParse(trek?.price?.replaceAll(',', '') ?? '0.00') ?? 0.00;
    String discountText = trek?.discountText ?? '';

    // Check if discount is percentage
    if (discountText.contains('%')) {
      // Extract percentage value
      String percentageStr = discountText.replaceAll(RegExp(r'[^\d.]'), '');
      double percentage = double.tryParse(percentageStr) ?? 0.0;
      // Calculate original price from discounted price: original = discounted / (1 - percentage/100)
      double originalPrice = discountedPrice / (1 - (percentage / 100));
      return originalPrice.toStringAsFixed(0);
    } else {
      // Check if discount is fixed amount
      String amountStr = discountText.replaceAll(RegExp(r'[^\d.]'), '');
      double discountAmount = double.tryParse(amountStr) ?? 0.0;
      double originalPrice = discountedPrice + discountAmount;
      return originalPrice.toStringAsFixed(0);
    }
  }

  // Method to format date from "2025-09-05" to "05-09-2025"
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      // Split the date string by '-'
      List<String> dateParts = dateString.split('-');
      if (dateParts.length == 3) {
        // Reorder from YYYY-MM-DD to DD-MM-YYYY
        return '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
      }
      return dateString; // Return original if format is unexpected
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92.w,
        // height: (trek.hasDiscount! || trek.badge != null) ? 23.h : 22.h,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.h),
          boxShadow: [
            BoxShadow(
              color: CommonColors.blackColor.withValues(alpha: 0.2),
              offset: Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 3.w, 1.4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: Image.asset(
                      CommonImages.logo4,
                      width: 12.w,
                      height: 12.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.8.h),
                        Text(
                          trek?.name ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          trek?.vendor ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            color: CommonColors.grey_AEAEAE,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (trek?.hasDiscount == true)
                        Container(
                          padding: EdgeInsets.fromLTRB(2.w, 0.6.h, 2.w, 0.6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEEFF),
                            borderRadius: BorderRadius.circular(0.8.h),
                          ),
                          child: Text(
                            trek?.discountText ?? '0%',
                            textScaler: const TextScaler.linear(1.0),
                            style: GoogleFonts.poppins(
                              color: CommonColors.blackColor,
                              fontSize: FontSize.s7,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                      else if (trek?.badge != null)
                        Container(
                          padding: EdgeInsets.fromLTRB(2.w, 0.6.h, 2.w, 0.6.h),
                          decoration: BoxDecoration(
                            color: _parseBadgeColor(trek?.badge?.color),
                            borderRadius: BorderRadius.circular(0.8.h),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                trek?.badge?.icon ?? '',
                                style: TextStyle(fontSize: FontSize.s6),
                              ),
                              SizedBox(width: 0.5.w),
                              Text(
                                trek?.badge?.name ?? '',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  color: CommonColors.blackColor,
                                  fontSize: FontSize.s7,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: trek?.hasDiscount == true ? 1.h : 2.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (trek?.hasDiscount == true) ...[
                              // Show original price with strikethrough
                              Text(
                                '₹${_getOriginalPrice()}',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.roboto(
                                  fontSize: FontSize.s8,
                                  fontWeight: FontWeight.w400,
                                  color: CommonColors.blackColor.withValues(
                                    alpha: 0.8,
                                  ),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              // SizedBox(height: 0.2.h),
                            ],
                            // Show discounted price or original price
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹ ',
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.roboto(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: trek?.hasDiscount == true
                                        ? CommonColors.softGreen3
                                        : CommonColors.blackColor,
                                  ),
                                ),
                                Text(
                                  trek?.hasDiscount == true
                                      ? _calculateDiscountedPrice()
                                      : (trek?.price ?? '0.00'),
                                  textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.roboto(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w800,
                                    color: trek?.hasDiscount == true
                                        ? CommonColors.softGreen3
                                        : CommonColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Onwards',
                              textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s9,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.blackColor.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: trek?.hasDiscount == true ? 1.h : 0.7.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trek Duration',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          trek?.duration ?? '-',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0.8.w, 0.25.h, 2.w, 0.4.h),
                    decoration: BoxDecoration(
                      gradient: getRatingColor(trek?.rating?.toDouble() ?? 0.0),
                      borderRadius: BorderRadius.circular(1.5.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 3.8.w),
                        SizedBox(width: 0.5.w),
                        Text(
                          "${trek?.rating ?? 0}",
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: trek?.hasDiscount == true ? 0.5.h : 1.2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure Date',
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.blackColor,
                          ),
                        ),
                        Text(
                          _formatDate(trek?.batchInfo?.startDate),
                          textScaler: const TextScaler.linear(1.0),
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s9,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.blackColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${trek?.batchInfo?.availableSlots} Slots left',
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      TextButton(
                        onPressed: showShare ? onShareTap : onViewItineraryTap,
                        style: TextButton.styleFrom(
                          // foregroundColor: const Color(0xFF2196F3),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                        ),
                        child: showShare
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.share_outlined,
                                    color: CommonColors.blackColor,
                                    size: 4.w,
                                  ),
                                  SizedBox(width: 1.5.w),
                                  Text(
                                    'Share',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s9,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.blueColor,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'View itinerary',
                                textScaler: const TextScaler.linear(1.0),
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.blueColor,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

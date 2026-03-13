// DiscountCardDetailsScreen.dart

import 'package:arobo_app/models/discount_card_model.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';

class DiscountCardDetailsScreen extends StatelessWidget {
  final DiscountCardModel discountCard;

  const DiscountCardDetailsScreen({
    super.key,
    required this.discountCard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonColors.lightBlueColor3.withOpacity(0.2),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Offers',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Redesigned Offer Banner with Right-Side Image
            Container(
              width: 100.w,
              padding: EdgeInsets.only(
                left: 3.5.h,
                right: 1.h,
                top: 2.5.h,
                bottom: 2.5.h,
              ),
              decoration: BoxDecoration(
                color: discountCard.color,
              ),
              child: Stack(
                children: [
                  // Right-side illustration
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      discountCard.imagePath,
                      height: discountCard.imageHeight ?? 12.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Left-side content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discountCard.title,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        discountCard.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            'upto ',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              color: CommonColors.blackColor,
                            ),
                          ),
                          Text(
                            '₹${discountCard.offerAmount}',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w700,
                              color: CommonColors.blackColor,
                            ),
                          ),
                          Text(
                            ' off*',
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s14,
                              color: CommonColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              discountCard.code,
                              style: GoogleFonts.archivoBlack(
                                fontSize: FontSize.s11,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: discountCard.code),
                                );
                                Get.snackbar(
                                  'Copied!',
                                  'Coupon code copied to clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                  margin: EdgeInsets.all(2.h),
                                );
                              },
                              child: Icon(
                                Icons.copy_rounded,
                                size: 5.w,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Detailed Description Section
            if (discountCard.detailedDescription?.isNotEmpty ?? false)
              _buildSection(
                title: 'About this offer',
                content: discountCard.detailedDescription!,
              ),

            // How to Apply Section
            if (discountCard.howToApply?.isNotEmpty ?? false)
              _buildSection(
                title: 'How to Apply',
                content: discountCard.howToApply!,
              ),

            // Terms & Conditions Section
            if (discountCard.termsAndConditions?.isNotEmpty ?? false)
              _buildSection(
                title: 'Terms & Conditions',
                content: discountCard.termsAndConditions!,
              ),

            // Footer Note Section
            if (discountCard.footerNote?.isNotEmpty ?? false)
              _buildSection(
                title: 'Note',
                content: discountCard.footerNote!,
              ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.5.h),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.2),
            offset: Offset(0, 0),
            blurRadius: 2,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
              color: CommonColors.blueColor,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: FontSize.s10,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

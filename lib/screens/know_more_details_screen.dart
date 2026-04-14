import 'package:arobo_app/models/know_more_data.dart';
import 'package:arobo_app/utils/app_theme.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';

class KnowMoreDetailsScreen extends StatelessWidget {
  final KnowMoreData? knowMoreData;

  const KnowMoreDetailsScreen({
    super.key,
    required this.knowMoreData,
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
          knowMoreData?.title ?? "",
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Redesigned Header Banner with Dynamic Curved Image and Text
            Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  // stops: [0.0, 0.5, 1],
                  colors: (knowMoreData?.customGradient?.isEmpty == true) ? [
                  Color(0xFFCF6565),
                    Color(0xFFCF6565),
                    ] :  (knowMoreData?.customGradient?.map((color) => AppTheme.hexToColor(color)).toList() ?? [])
                )
              ),
              child: Stack(
                children: [
                  // Circular shape in the top-left corner
                  Positioned(
                    top: -6.h,
                    left: -6.h,
                    child: Container(
                      width: 25.h,
                      height: 25.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Image positioned over the white shape
                  Positioned(
                    top: 2.h,
                    left: 2.h,
                    child: SizedBox(
                      width: 13.h,
                      height: 13.h,
                      child: Stack(
                        children: [
                          // Shadow image (fills the Stack, with offset)
                          Positioned.fill(
                            child: Transform.translate(
                              offset: const Offset(0, 4),
                              child: ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.45),
                                    BlendMode.srcATop,
                                  ),
                                  child: CustomNetworkImage(imageUrl: knowMoreData?.imagePath ?? "",width: 50,height: 50,fit:BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                          CustomNetworkImage(imageUrl: knowMoreData?.imagePath ?? "",height: 13.h,
                              width: 13.h,fit:BoxFit.cover)
                          // Main image
                        ],
                      ),
                    ),
                  ),

                  // Text content positioned at the bottom
                  Positioned(
                    bottom: 5.h,
                    left: 20.h,
                    // right: 3.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Introduction to',
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color:AppTheme.hexToColor(knowMoreData?.textColor ?? ""),
                          ),
                        ),
                        // SizedBox(height: 1.h),
                        Text(
                          knowMoreData?.title ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: FontSize.s14,
                            fontWeight: FontWeight.w600,
                            color:AppTheme.hexToColor(knowMoreData?.textColor ?? ""),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Detailed Title Section
            if (knowMoreData?.detailedTitle != null)
              Container(
                // width: 100.w,
                margin: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                // padding: EdgeInsets.all(2.h),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(1.5.h),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.05),
                //       blurRadius: 10,
                //       offset: const Offset(0, 2),
                //     ),
                //   ],
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      knowMoreData?.detailedTitle ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blueColor,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    if (knowMoreData?.detailedDescription != null)
                      Text(
                        knowMoreData?.detailedDescription ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),

            // Bullet Points Section
            if (knowMoreData?.bulletPoints?.isNotEmpty ?? false)
              Container(
                // width: 100.w,
                margin: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                //  padding: EdgeInsets.all(2.h),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(1.5.h),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.05),
                //       blurRadius: 10,
                //       offset: const Offset(0, 2),
                //     ),
                //   ],
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why Should You Care?',
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.blueColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ...(knowMoreData?.bulletPoints ?? [])
                        .map((point) => _buildBulletPoint(
                              title: point.title ?? '',
                              description: point.description ?? '',
                            )),
                  ],
                ),
              ),

            // Call to Action Section
            if (knowMoreData?.callToAction?.isNotEmpty ?? false)
              _buildSection(
                title: 'Ready to Start?',
                content: knowMoreData?.callToAction ?? "",
                isCallToAction: true,
              ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isMainTitle = false,
    bool isCallToAction = false,
  }) {
    return Container(
      // width: 100.w,
      margin: EdgeInsets.symmetric(horizontal: 2.h),
      // padding: EdgeInsets.all(2.h),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(1.5.h),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 10,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMainTitle)
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w600,
                color: CommonColors.blueColor,
              ),
            ),
          if (!isMainTitle) SizedBox(height: 1.5.h),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: isMainTitle ? FontSize.s10 : FontSize.s9,
              height: 1.5,
              fontWeight: isMainTitle ? FontWeight.w600 : FontWeight.w400,
              color: isMainTitle ? CommonColors.blueColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(
      {required String title, required String description}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.8.h),
            width: 1.5.w,
            height: 1.5.w,
            decoration: BoxDecoration(
              color: CommonColors.blackColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s10,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

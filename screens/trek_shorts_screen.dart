import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:arobo_app/models/shorts_treks_data.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TrekShortsScreen extends StatelessWidget {
  const TrekShortsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.offWhiteColor2,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: CommonColors.blackColor),
        title: Text(
          'Trek Shorts',
          style: GoogleFonts.poppins(
            color: CommonColors.blackColor,
            fontSize: FontSize.s11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.7,
          ),
          itemCount: shortsTreksCardsData.length,
          itemBuilder: (context, index) {
            final cardData = shortsTreksCardsData[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.5.h),
                boxShadow: [
                  BoxShadow(
                    color: CommonColors.blackColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.5.h),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Image.asset(
                      cardData['imagePath'],
                      fit: BoxFit.cover,
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            CommonColors.transparent,
                            CommonColors.blackColor.withValues(alpha: 0.7),
                          ],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(1.5.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardData['title'] ??
                                'Lorem ipsum | Sit amet | consectetur adipiscing elit..',
                            style: GoogleFonts.poppins(
                              color: CommonColors.whiteColor,
                              fontSize: 6.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${cardData['views'] ?? '4M'} views',
                            style: GoogleFonts.poppins(
                              color: CommonColors.whiteColor,
                              fontSize: 6.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

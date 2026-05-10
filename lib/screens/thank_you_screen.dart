import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/common_bottom_nav.dart';
import 'package:flutter/material.dart';

// import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CommonBottomNav(
        selectedIndex: selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIconColor: CommonColors.appYellowColor,
        unselectedIconColor: Colors.black,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: true,
            expandedHeight: 0,
            collapsedHeight: kToolbarHeight,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 22.h,
                        child: Image.asset(
                          CommonImages.thankYou,
                          width: 6.w,
                          height: 6.w,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Thank You for Showing\nInterest !',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Your dream trek is with our\nTrail Masters you\'re in expert hands.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w400,
                          color: CommonColors.blackColor.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'They will contact you soon.',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w400,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: CommonColors.borderColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color: CommonColors.blackColor,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Frequently Asked Questions',
                                    style: GoogleFonts.poppins(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w400,
                                      color: CommonColors.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: CommonColors.blackColor,
                                size: 4.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                // ➕ Added this new section right below Seasonal Forecast
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 30.0, left: 0, right: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Go Beyond,\nExplore More!',
                        textAlign: TextAlign.start,
                        // textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.sourceSerif4(
                          fontSize: FontSize.s28,
                          fontWeight: FontWeight.bold,
                          color: CommonColors.greyColorf7f7f7
                              .withValues(alpha: 0.5),
                          height: 1.3,
                          letterSpacing: 1.8,
                        ),
                      ),
                      SizedBox(height: ScreenConstant.size20),
                      RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: FontSize.s14,
                            color: CommonColors.greyColorf7f7f7,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Crafted with passion  ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.bottom,
                              child: Icon(Icons.favorite,
                                  color: CommonColors.red_B52424,
                                  size: FontSize.s12),
                            ),
                            TextSpan(
                              text: '\nrooted in Hyderabad.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

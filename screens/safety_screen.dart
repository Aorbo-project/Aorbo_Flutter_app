import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_images.dart';
import '../utils/common_safety_card.dart';
import '../utils/common_colors.dart';
import '../utils/common_bottom_nav.dart';
import '../utils/screen_constants.dart';
import 'package:get/get.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int selectedIndex = 0;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;

  final List<Map<String, dynamic>> safetyCards = [
    {
      'title': "Explore The Wild With Confidence.",
      'subtitle':
          "AoRbo connects you with trusted trekking partners, experienced guides & safety equipment. Book your next trek safely and enjoy where safety meets excitement.",
      'gradientColors': [
        CommonColors.materialPurple.withValues(alpha: 0.6),
        CommonColors.materialPink.withValues(alpha: 0.6),
      ],
      'backgroundImage': CommonImages.safety1,
    },
    {
      'title': "Safety First\nAdventure Second.",
      'subtitle':
          "Our certified guides and well-maintained equipment ensure your safety throughout the journey. Experience thrilling adventures with peace of mind.",
      'gradientColors': [
        CommonColors.materialBlue.withValues(alpha: 0.8),
        CommonColors.materialTeal.withValues(alpha: 0.8),
      ],
      'backgroundImage': CommonImages.safety2,
    },
    {
      'title': "24/7 Support\nAt Your Service.",
      'subtitle':
          "Round-the-clock assistance and emergency support available throughout your trek. Your safety is our top priority.",
      'gradientColors': [
        CommonColors.materialDeepOrange.withValues(alpha: 0.8),
        CommonColors.materialAmber.withValues(alpha: 0.8),
      ],
      'backgroundImage': CommonImages.safety3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isUserInteracting && mounted) {
        final nextPage = (_currentPage + 1) % safetyCards.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Safety',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Light blue background extension
          Container(
            height: 8.h,
            color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // Header Container with Shadow
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 4.h, bottom: 1.h),
                  padding: EdgeInsets.only(
                    left: 2.h,
                    right: 5.h,
                    top: 4.h,
                    // bottom: 2.w,
                  ),
                  decoration: BoxDecoration(
                    color: CommonColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.w),
                      topRight: Radius.circular(6.w),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "At Aorbo, YAt Aorbo, Your Safety comes first. Here are some measures and provisions to ensure your safety.",
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.blackColor.withValues(alpha: 0.8),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle know more action
                          },
                          child: Text(
                            "Know more",
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s10,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.materialBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Safety Cards PageView with Gesture Detection
                GestureDetector(
                  onPanDown: (_) {
                    setState(() => _isUserInteracting = true);
                  },
                  onPanCancel: () {
                    setState(() => _isUserInteracting = false);
                  },
                  onPanEnd: (_) {
                    setState(() => _isUserInteracting = false);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    height: 26.h,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: safetyCards.length,
                      itemBuilder: (context, index) {
                        return CommonSafetyCard(
                          title: safetyCards[index]['title'],
                          subtitle: safetyCards[index]['subtitle'],
                          backgroundImage: safetyCards[index]
                              ['backgroundImage'],
                          logoPath: CommonImages.logo2,
                          height: 25.h,
                          width: 100.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          borderRadius: BorderRadius.circular(24),
                          gradientColors: safetyCards[index]['gradientColors'],
                          onTap: () {
                            // Handle tap
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Progress Indicator
                SizedBox(height: 1.h),

                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                //   child: Stack(
                //     children: [
                //       // Background track
                //       Container(
                //         height: 1.h,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(30),
                //           color: CommonColors.greyColor818181,
                //         ),
                //       ),
                //       // Progress indicator
                //       AnimatedContainer(
                //         duration: const Duration(milliseconds: 300),
                //         height: 1.h,
                //         width: (100.w - 30.w) *
                //             ((_currentPage + 1) / safetyCards.length),
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(30),
                //           color: CommonColors.materialYellowColor2,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // Settings Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        "Settings",
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CommonColors.greyColorf7f7f7
                                .withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.blackColor
                                  .withValues(alpha: 0.1),
                              offset: Offset(2, 2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/emergency-contacts');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(2.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Trusted contacts",
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "Share your trip details to your trusted persons in one click",
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s9,
                                    color: CommonColors.grey_767676,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(
        selectedIndex: selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIconColor: CommonColors.appYellowColor,
        unselectedIconColor: CommonColors.blackColor,
      ),
    );
  }
}

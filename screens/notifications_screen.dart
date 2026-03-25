import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/common_bottom_nav.dart';
import '../utils/screen_constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedIndex = 0;

  final List<Map<String, String>> notifications = [
    {
      "title": "🌄 Adventure Awaits!",
      "body":
          "New treks have just been added. Ready to discover your next great adventure?\nStart exploring today!"
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
    {
      "title": "‍♂️ Ready to Trek?",
      "body":
          "The trails are calling! Book your next unforgettable trek and create memories that last forever."
    },
  ];

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
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background light blue color at top
          Container(
            height: 8.h,
            color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),

          // White foreground container that starts below AppBar background
          Container(
            margin:
                EdgeInsets.only(top: 4.h), // add spacing below the colored top
            padding:
                EdgeInsets.only(top: 2.h, left: 4.w, right: 4.w, bottom: 4.h),
            decoration: BoxDecoration(
              color: CommonColors.offWhiteColor3,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6.w),
                topRight: Radius.circular(6.w),
              ),
            ),
            child: ListView.builder(
              itemCount: notifications.length,
              padding: EdgeInsets.only(bottom: 2.h),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: const BoxDecoration(
                            color: CommonColors.blackColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title']!,
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                notification['body']!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  color: CommonColors.blackColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Divider(
                      thickness: 1,
                      color:
                          CommonColors.greyColorf7f7f7.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 2.h),
                  ],
                );
              },
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

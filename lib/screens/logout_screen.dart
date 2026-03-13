import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
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
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 5.h,
            color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),
          Container(
            // color: Colors.red,
            width: double.infinity,
            height: 320,
            padding: EdgeInsets.all(30),
            margin: EdgeInsets.only(top: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Are you sure you want to log out?",
                  style: TextStyle(
                    fontSize: FontSize.s14,
                    color: CommonColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "You will be asked to Login ,Once you’ve \n Logged Out.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: CommonColors.grey_767676,
                  ),
                ),
                SizedBox(height: 5),
                CommonButton(
                  text: "Logout",
                  width: 80.w,
                  isFullWidth: false,
                  onPressed: () {
                    CommonLogics.logOut();
                  },
                  textColor: CommonColors.whiteColor,
                  backgroundColor: CommonColors.grey_AEAEAE,
                ),
                SizedBox(height: 5),
                CommonButton(
                  text: "Cancel",
                  width: 80.w,
                  isFullWidth: false,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  gradient: CommonColors.filterGradient,
                  textColor: CommonColors.whiteColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../utils/common_btn.dart';
import '../utils/screen_constants.dart';

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
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
            'Claims',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w500,
              color: CommonColors.blackColor,
            ),
          ),
        ),
        body: Column(
          children: [
            // Light blue background extension
            Container(
              height: 4.h,
              color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
            ),
            Container(
              padding: EdgeInsets.all(5.w),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "POLICY COVERAGE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CommonColors.blackColor, // or CommonColors.blackColor
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.all(5.w),
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: CommonColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: CommonColors.greyColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBenefitRow(
                          iconPath:
                              'assets/images/img/medicalexpensesinsurance.png',
                          title: 'Medical Expense for Hospitalization',
                          amount: 'Up to ₹ 1,00,000',
                        ),
                        SizedBox(height: 1.h),
                        _buildBenefitRow(
                          iconPath: 'assets/images/img/caraccident.png',
                          title: 'Personal Accident / Accidental Death',
                          amount: 'Up to ₹ 5,00,000',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "LEGAL",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CommonColors.blackColor, // or CommonColors.blackColor
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.all(5.w),
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: CommonColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: CommonColors.greyColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Claim Procedure",
                              style: TextStyle(fontSize: 9),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "View Details",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: CommonColors.materialBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Terms and Conditions",
                              style: TextStyle(fontSize: 9),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "View Details",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: CommonColors.materialBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Container(
                    width: 90.w,
                    // responsive width (90% of screen width)
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    // add some horizontal padding
                    child: const Text(
                      "Kindly provide your accurate email address, date of\n"
                      "birth, and phone number to prevent any delays or cancellations of your insurance claim.",
                      style: TextStyle(fontSize: 7),
                      textAlign: TextAlign.start, // left-align text
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: const BoxDecoration(
                                color: CommonColors.blackColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Powered by (Insurance company name)",
                              style: TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        CommonButton(
                          text: 'Claim Insurance',
                          onPressed: () async {},
                          gradient: CommonColors.btnGradient,
                          textColor: CommonColors.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: FontSize.s11,
                          height: 6.5.h,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildBenefitRow({
    required String iconPath,
    required String title,
    required String amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      // Align image + text center
      children: [
        Image.asset(
          iconPath,
          width: 8.w,
          height: 7.h,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // avoid unnecessary space
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.blackColor,
                ),
              ),
              SizedBox(height: 0.3.h), // smaller gap for tighter alignment
              Text(
                amount,
                style: TextStyle(
                  fontSize: 7,
                  color: CommonColors.greyColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

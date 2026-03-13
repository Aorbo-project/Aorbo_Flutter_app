import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';

// Custom painter for ticket shape with shadow
class TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = CommonColors.blackColor.withValues(alpha: 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

    final Paint mainPaint = Paint()
      ..color = CommonColors.whiteColor
      ..style = PaintingStyle.fill;

    final double radius = 5.5.w;
    final double circleRadius = 4.5.w;

    final path = Path();
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, (size.height / 2) - circleRadius);
    path.arcToPoint(
      Offset(size.width, (size.height / 2) + circleRadius),
      radius: Radius.circular(circleRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, (size.height / 2) + circleRadius);
    path.arcToPoint(
      Offset(0, (size.height / 2) - circleRadius),
      radius: Radius.circular(circleRadius),
      clockwise: false,
    );
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    // Draw shadow first
    canvas.drawPath(path.shift(Offset(2, 2)), shadowPaint);
    // Draw main shape
    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Refer extends StatefulWidget {
  const Refer({super.key});

  @override
  State<Refer> createState() => _ReferState();
}

class _ReferState extends State<Refer> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  String referralCode = "AO12345";
  bool _copied = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: referralCode));
    setState(() {
      _copied = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _copied = false;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.whiteColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: CommonColors.blackColor,
        ),
        title: Text(
          'Refer & Earn',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w500,
            color: CommonColors.blackColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              SizedBox(height: ScreenConstant.size20),
              _buildGreenReferBox(),
              SizedBox(height: 3.h),
              _buildReferralCode(),
              SizedBox(height: 3.h),
              _buildTabBar(),
              SizedBox(height: 3.h),
              _selectedTabIndex == 0
                  ? _buildReferAndEarnContent()
                  : _buildReferralHistoryContent(),
            ],
          ),
        ),
      ),
    );
  }
}

  Widget _buildGreenReferBox() {
    return Container(
      width: 100.w,
      height: 26.h,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7ECBA1),
            Color(0xFF4BB7DE),
          ],
        ),
        borderRadius: BorderRadius.circular(6.w),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.2),
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 2,
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Refer & Earn ₹ 1000!",
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.whiteColor,
                ),
              ),
              SizedBox(height: ScreenConstant.size20),
              SizedBox(
                width: 60.w, // Reduced width to make space for image
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 2.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CommonColors.whiteColor,
                              ),
                            ),
                            Container(
                              width: 1.5.w,
                              height: 4.h,
                              color: CommonColors.ceced.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            "You will receive a ₹50 cashback when a friend completes their first trek using your referral coupon.",
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s8,
                              color: CommonColors.whiteColor,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 2.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CommonColors.whiteColor,
                              ),
                            ),
                            Container(
                              width: 1.5.w,
                              height: 4.h,
                              color: CommonColors.ceced.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            "Your friend will receive a flat ₹50 discount on their first trek booking.",
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s8,
                              color: CommonColors.whiteColor,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CommonColors.whiteColor,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            "You will receive a ₹1000 cashback for the first twenty successful referrals.",
                            style: GoogleFonts.poppins(
                              fontSize: FontSize.s8,
                              color: CommonColors.whiteColor,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScreenConstant.size20),
            ],
          ),
          Positioned(
            right: 0,
            left: 25.h,
            top: 13.h,
            bottom: 0,
            child: Image.asset(
              CommonImages.referandearn,
              width: 28.w,
              height: 12.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBulletPoint(String text) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         margin: EdgeInsets.only(top: 1.w, right: 2.w),
  //         width: 1.5.w,
  //         height: 1.5.w,
  //         decoration: BoxDecoration(
  //           color: CommonColors.whiteColor,
  //           shape: BoxShape.circle,
  //         ),
  //       ),
  //       Expanded(
  //         child: Text(
  //           text,
  //           style: GoogleFonts.poppins(
  //             fontSize: 10.sp,
  //             color: CommonColors.whiteColor,
  //             height: 1.4,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildReferralCode() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.5.w),
      height: 12.h,
      child: CustomPaint(
        painter: TicketPainter(),
        child: Container(
          margin: EdgeInsets.only(
            left: 6.w,
            right: 6.w,
            top: 2.h,
            bottom: 2.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your referral code',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s9,
                  fontWeight: FontWeight.w400,
                  color: CommonColors.blackColor.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF0004FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      'AO12345',
                      style: GoogleFonts.archivoBlack(
                        fontSize: FontSize.s11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                        color: CommonColors.blackColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: 'AO12345'));
                      setState(() {
                        _copied = true;
                      });
                      await Future.delayed(Duration(seconds: 1));
                      setState(() {
                        _copied = false;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 2.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9CB0FF).withValues(alpha: 0.9),
                            Color(0xFF9CC5FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: _copied
                            ? Icon(
                                Icons.check,
                                color: CommonColors.blackColor,
                                size: 5.w,
                              )
                            : Text(
                                'Copy',
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s10,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.blackColor,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      width: 100.w,
      child: Row(
        children: [
          _buildTabItem("Refer and earn", 0),
          _buildTabItem("Referral history", 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w500,
                color: isSelected ? CommonColors.blackColor : Colors.grey,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              height: 0.3.h,
              color: isSelected ? CommonColors.blueColor : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferAndEarnContent() {
    return Column(
      children: [
        _buildSteps(),
        SizedBox(height: 4.h),
        _buildButton(
          text: "Get friends to refer",
          isOutlined: true,
          onPressed: () {},
        ),
        SizedBox(height: ScreenConstant.size20),
        _buildButton(
          text: "Refer Now",
          isOutlined: false,
          onPressed: () {},
        ),
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildSteps() {
    return Column(
      children: [
        _buildReferStep(
          number: "1",
          text:
              "Share your referral link via WhatsApp, SMS, email, and other platforms.",
          imagePath: "assets/images/cover/womanspeak.png",
        ),
        _buildReferStep(
          number: "2",
          text:
              "Your friend clicks on the referral link and registers an account.",
          imagePath: "assets/images/cover/mobilephone.png",
        ),
        _buildReferStep(
          number: "3",
          text:
              "Earn cashback when a friend completes their first trek using your referral.",
          imagePath: "assets/images/img/approval.png",
          isLastStep: true,
        ),
      ],
    );
  }

  Widget _buildReferStep({
    required String number,
    required String text,
    required String imagePath,
    bool isLastStep = false,
  }) {
    final bool isEvenStep = number == "2"; // Image on right for step 2

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEvenStep) ...[
            // Image on left for odd numbered steps
            SizedBox(
              width: 25.w,
              height: 25.w,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 4.w),
          ],
          // Text content in middle
          Expanded(
            child: Column(
              crossAxisAlignment: isEvenStep
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: CommonColors.blueColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  text,
                  textAlign: isEvenStep ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: FontSize.s9,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isEvenStep) ...[
            // Image on right for even numbered steps
            SizedBox(width: 4.w),
            SizedBox(
              width: 25.w,
              height: 25.w,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ],
          if (!isLastStep) ...[
            SizedBox(height: ScreenConstant.size20),
          ],
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isOutlined,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 100.w,
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        gradient: !isOutlined ? CommonColors.btnGradient : null,
        color: isOutlined ? Colors.white : null,
        border: isOutlined ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.2),
            offset: Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 2,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(3.w),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isOutlined ? Colors.grey.shade700 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralHistoryContent() {
    return Column(
      children: [
        Container(
          width: 100.w,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: CommonColors.whiteColor,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹0.00",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Total rewards",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Image.asset(
                "assets/images/cover/moneytransfer.png",
                width: 20.w,
                height: 10.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        SizedBox(height: 25.h),
        Text(
          "Invite your friends and earn exciting rewards!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 3.h),
        _buildButton(
          text: "Refer Now",
          isOutlined: false,
          onPressed: () {},
        ),
        SizedBox(height: 3.h),
      ],
    );
  }
}

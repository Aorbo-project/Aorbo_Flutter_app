import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Background: same homeScreenBgGradient used elsewhere in the app
      body: Container(
        decoration: const BoxDecoration(
          gradient: CommonColors.homeScreenBgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: BoxDecoration(
                          color: CommonColors.whiteColor.withValues(
                            alpha: 0.85,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CommonColors.c0A000000,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: CommonColors.cFF111827,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: FontSize.s16,
                        fontWeight: FontWeight.w700,
                        color: CommonColors.cFF111827,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Main card
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 4.h),
                    decoration: BoxDecoration(
                      color: CommonColors.whiteColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: CommonColors.cFF111827.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Logout SVG icon in a styled badge
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: CommonColors.cFFFFE4E4,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CommonColors.cFFDC2626.withValues(
                                alpha: 0.18,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              CommonImages.logout,
                              width: 8.w,
                              height: 8.w,
                              colorFilter: const ColorFilter.mode(
                                CommonColors.cFFDC2626,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 2.5.h),

                        // ── Headline
                        Text(
                          'Leaving so soon?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s18,
                            fontWeight: FontWeight.w700,
                            color: CommonColors.cFF111827,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: 1.h),

                        // ── Subtext
                        Text(
                          'You will be asked to login again\nonce you\'ve logged out.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: FontSize.s11,
                            color: CommonColors.cFF6B7280,
                            height: 1.6,
                          ),
                        ),

                        SizedBox(height: 1.5.h),

                        // ── Thin divider
                        Container(
                          height: 1,
                          color: CommonColors.cFFE5E7EB,
                          margin: EdgeInsets.symmetric(vertical: 1.h),
                        ),

                        SizedBox(height: 0.5.h),

                        // ── Logout button  (red solid — destructive action)
                        CommonButton(
                          text: 'Yes, Logout',
                          isFullWidth: true,
                          backgroundColor: CommonColors.cFFDC2626,
                          textColor: CommonColors.whiteColor,
                          fontWeight: FontWeight.w700,
                          borderRadius: 14,
                          elevation: 0,
                          prefixIcon: SvgPicture.asset(
                            CommonImages.logout,
                            width: 4.5.w,
                            height: 4.5.w,
                            colorFilter: const ColorFilter.mode(
                              CommonColors.whiteColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () => CommonLogics.logOut(),
                        ),

                        SizedBox(height: 1.4.h),

                        // ── Cancel button (app's filterGradient — blue)
                        CommonButton(
                          text: 'Cancel',
                          isFullWidth: true,
                          gradient: CommonColors.filterGradient,
                          textColor: CommonColors.whiteColor,
                          fontWeight: FontWeight.w600,
                          borderRadius: 14,
                          elevation: 0,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Aorbo logo watermark at bottom
              Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset(CommonImages.logo2, height: 3.5.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

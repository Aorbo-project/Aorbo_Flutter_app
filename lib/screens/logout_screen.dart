import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen>
    with TickerProviderStateMixin {
  // Logo animations (same as splash)
  late AnimationController _logoController;
  late Animation<Alignment> _logoAlignmentAnimation;
  late Animation<double> _logoWidthAnimation;
  late Animation<double> _logoHeightAnimation;

  // Form slide-up animation (same as splash)
  late AnimationController _formController;
  late Animation<Offset> _formOffsetAnimation;

  // Breathing animation for logo (same as splash)
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Button press animation (same as login)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _splashDone = false;
  bool _formSlideDone = false;
  bool _isLoggingOut = false;

  bool _logoutPressed = false;
  bool _cancelPressed = false;

  @override
  void initState() {
    super.initState();

    // Logo controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAlignmentAnimation = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0.0, -0.88),
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoWidthAnimation = Tween<double>(
      begin: 70.w,
      end: 46.w,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoHeightAnimation = Tween<double>(
      begin: 50.h,
      end: 10.h,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Form slide controller
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _formOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));

    // Breathing controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Button scale controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Choreograph: logo finishes -> form slides up
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() => _splashDone = true);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          _formController.forward();
        });
      }
    });

    _formController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() => _formSlideDone = true);
      }
    });

    // Kick off logo animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _breathingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await Future.delayed(const Duration(milliseconds: 350));
    CommonLogics.logOut();
  }

  @override
  Widget build(BuildContext context) {
    ScreenConstant.setScreenAwareConstant(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background gradient (same as splash)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFEF200),
                  Color(0xFFFFA000),
                ],
              ),
            ),
          ),

          // Animated logo with shimmer + breathing (same as splash)
          AnimatedBuilder(
            animation: Listenable.merge([_logoController, _breathingController]),
            builder: (context, child) {
              final baseLogo = SizedBox(
                width: _logoWidthAnimation.value,
                height: _logoHeightAnimation.value,
                child: Image.asset(
                  CommonImages.logo1,
                  fit: BoxFit.contain,
                ),
              );

              final breathingLogo = ScaleTransition(
                scale: _breathingAnimation,
                child: baseLogo,
              );

              final shimmerLogo = _splashDone
                  ? Shimmer.fromColors(
                      baseColor: Colors.black,
                      highlightColor: Colors.white.withOpacity(0.6),
                      period: const Duration(milliseconds: 3000),
                      direction: ShimmerDirection.ltr,
                      child: breathingLogo,
                    )
                  : baseLogo;

              return Align(
                alignment: _logoAlignmentAnimation.value,
                child: shimmerLogo,
              );
            },
          ),

          // Sliding white panel from bottom (same as splash)
          SlideTransition(
            position: _formOffsetAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 70.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xffFFFDF9),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.w)),
                ),
                child: _buildLogoutContent(),
              ),
            ),
          ),

          // Back button (top-left, appears with form)
          if (_formSlideDone)
            Positioned(
              top: MediaQuery.of(context).padding.top + 1.h,
              left: 4.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 5.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline (same styling family as splash login)
          Text(
            "Leaving",
            style: GoogleFonts.sairaStencilOne(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            "so",
            style: GoogleFonts.sairaStencilOne(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            "soon ?",
            style: GoogleFonts.sairaStencilOne(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 3.h),

          // Logout icon badge with breathing pulse
          Center(
            child: ScaleTransition(
              scale: _breathingAnimation,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFEE2E2),
                      const Color(0xFFFECACA).withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFFDC2626).withOpacity(0.18),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    CommonImages.logout,
                    width: 8.w,
                    height: 8.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFDC2626),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Subtext
          Center(
            child: Text(
              "You'll need to sign in again\nto continue your adventure.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Logout button (matches login button press behavior)
          GestureDetector(
            onTapDown: (_) {
              if (!_isLoggingOut) {
                setState(() => _logoutPressed = true);
                _animationController.forward();
              }
            },
            onTapUp: (_) {
              setState(() => _logoutPressed = false);
              _animationController.reverse();
            },
            onTapCancel: () {
              setState(() => _logoutPressed = false);
              _animationController.reverse();
            },
            onTap: _isLoggingOut ? null : _handleLogout,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.h),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEF4444),
                      Color(0xFFDC2626),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626)
                          .withOpacity(_logoutPressed ? 0.2 : 0.4),
                      blurRadius: _logoutPressed ? 8 : 18,
                      spreadRadius: -2,
                      offset: Offset(0, _logoutPressed ? 2 : 8),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoggingOut
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              CommonImages.logout,
                              width: 4.5.w,
                              height: 4.5.w,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Text(
                              'Yes, Logout',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: FontSize.s14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // Cancel button
          GestureDetector(
            onTapDown: (_) => setState(() => _cancelPressed = true),
            onTapUp: (_) => setState(() => _cancelPressed = false),
            onTapCancel: () => setState(() => _cancelPressed = false),
            onTap: () => Navigator.pop(context),
            child: AnimatedScale(
              scale: _cancelPressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.h),
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

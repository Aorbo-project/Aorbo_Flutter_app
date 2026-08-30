import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/controller/otp_controller.dart';
import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/phone_input_formatter.dart';
import 'package:arobo_app/screens/update_version_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/widgets/otp_success_overlay.dart';
import 'package:arobo_app/widgets/dissolve_to_dashboard.dart';

class SplashWithLoginScreen extends StatefulWidget {
  const SplashWithLoginScreen({super.key});

  @override
  State<SplashWithLoginScreen> createState() => _SplashWithLoginScreenState();
}

class _SplashWithLoginScreenState extends State<SplashWithLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Alignment> _logoAlignmentAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceOpacity;
  late Animation<double> _entranceScale;
  late AnimationController _exitFadeController;
  late Animation<double> _exitFadeOpacity;
  late AnimationController _formController;
  late Animation<Offset> _formOffsetAnimation;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late final OTPController _otpC;
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Animation<double>? _shakeAnimation;

  final AuthController _authC = Get.put(AuthController(), permanent: true);

  bool isValid = false;
  bool showOtp = false;
  bool _splashDone = false;
  bool _formSlideDone = false;
  bool _leavingToDashboard = false;
  bool _showOtpSuccessOverlay = false;

  Timer? _timer;
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpC = Get.put(OTPController());

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _logoAlignmentAnimation =
        AlignmentTween(
          begin: Alignment.center,
          end: const Alignment(0.0, -0.88),
        ).animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
        );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entranceOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _entranceScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _exitFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _exitFadeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitFadeController, curve: Curves.easeOut),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _formOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
        );

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation =
        Tween<double>(begin: 0.0, end: 24.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticIn,
          ),
        )..addListener(() {
          if (mounted) setState(() {});
        });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _otpController = TextEditingController();

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _splashDone = true;
        });
        if (!_breathingController.isAnimating) {
          _breathingController.forward();
        }
        _proceedAfterLogoLanded();
      }
    });

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _logoController.forward();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  Future<void> _proceedAfterLogoLanded() async {
    if (!mounted) return;
    await appBootstrapFuture;
    if (!mounted) return;

    final validateResponse = await _authC.validateVersion();

    if (validateResponse?.updateRequired == true) {
      Get.offAll(() => UpdateVersionScreen(dataModel: validateResponse));
      return;
    }

    if (CommonLogics.checkUserLogin()) {
      final sessionValid = await _authC.validateSession();
      if (!mounted) return;

      if (sessionValid) {
        _authC.registerFcmToken();
        _goToDashboard();
      } else {
        await sp!.clear();
        _startFormAnimation();
      }
    } else {
      _startFormAnimation();
    }
  }

  void _goToDashboard() {
    if (!mounted) {
      Get.offAllNamed('/dashboard');
      return;
    }
    _breathingController.stop();
    setState(() => _leavingToDashboard = true);
    _exitFadeController.forward();
    dissolveToDashboard(
      context,
      cover: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEF200), Color(0xFFFFA000)],
          ),
        ),
      ),
    );
  }

  void _startFormAnimation() {
    if (!mounted) return;
    _formController.forward();
    _formController.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        setState(() {
          _formSlideDone = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    if (_timer?.isActive == true) _timer?.cancel();
    _logoController.dispose();
    _entranceController.dispose();
    _exitFadeController.dispose();
    _formController.dispose();
    _breathingController.dispose();
    _animationController.dispose();
    _phoneFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (isValidPhoneNumber && !_authC.isProfileLoading.value) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!_authC.isLoading.value) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!_authC.isLoading.value) {
      _animationController.reverse();
    }
  }

  bool get isValidPhoneNumber =>
      _authC.phoneNumberLoginTextField.value.text.length == 10;

  Widget _buildOtpContainer() {
    bool isError = false;

    final defaultPinTheme = PinTheme(
      width: 13.w,
      height: 7.h,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: AppType.clampFontSize(18.sp),
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFA500), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA500).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: Colors.green.shade400, width: 2),
      ),
    );

    void validateOTP(String pin) async {
      if (!mounted) return;
      try {
        if (pin.length == 6) {
          setState(() {
            isError = false;
          });

          final phone = _authC.phoneNumberLoginTextField.value.text;
          final bool verified = await _authC.verifyOtp(phone, pin);

          if (!mounted) return;

          if (verified) {
            _authC.phoneNumberLoginTextField.value.clear();
            setState(() {
              _showOtpSuccessOverlay = true;
            });
          } else {
            setState(() {
              isError = true;
            });
            if (mounted) {
              _authC.otpTextField.value.clear();
              _pinFocusNode.requestFocus();
            }
          }
        } else {
          if (!mounted) return;
          CustomSnackBar.show(
            Get.context!,
            message: 'Please enter complete OTP',
          );
        }
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.show(
          Get.context!,
          message: 'Something went wrong. Please try again.',
        );
      }
    }

    return OtpSuccessOverlay(
      play: _showOtpSuccessOverlay,
      onFinished: _goToDashboard,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => showOtp = false),
                  child: Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                      size: 18,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  "Verify OTP",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppType.clampFontSize(18.sp),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              "Enter Verification Code",
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppType.clampFontSize(24.sp),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 1.h),
            Text.rich(
              TextSpan(
                text: "We sent a 6-digit code to ",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppType.clampFontSize(13.sp),
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: "+91 ${_authC.phoneNumberLoginTextField.value.text}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppType.clampFontSize(13.sp),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Align(
              alignment: Alignment.center,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Transform.translate(
                  offset: isError
                      ? Offset(_shakeAnimation?.value ?? 0, 0)
                      : Offset.zero,
                  child: Pinput(
                    length: 6,
                    controller: _authC.otpTextField.value,
                    focusNode: _pinFocusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    separatorBuilder: (index) => SizedBox(width: 3.w),
                    onCompleted: validateOTP,
                    onChanged: (value) {
                      if (isError) {
                        setState(() {
                          isError = false;
                        });
                      }
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: 16,
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA500),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Obx(
              () => Center(
                child: _otpC.enableResend.value
                    ? GestureDetector(
                        onTap: () => _otpC.resendOTP(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          child: Text(
                            'Resend Code via SMS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppType.clampFontSize(13.sp),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFA500),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _otpC.formatTime(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppType.clampFontSize(14.sp),
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Trek,",
            style: GoogleFonts.sairaStencilOne(
              fontSize: AppType.clampFontSize(26.sp),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
          Text(
            "just a",
            style: GoogleFonts.sairaStencilOne(
              fontSize: AppType.clampFontSize(26.sp),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
          Text(
            "Click Away !",
            style: GoogleFonts.sairaStencilOne(
              fontSize: AppType.clampFontSize(26.sp),
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFA500), // Rich brand highlight
              height: 1.1,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Enter your mobile number to get started with a seamless experience.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppType.clampFontSize(13.sp),
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          SizedBox(height: 5.h),

          // Premium Phone Input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(color: Colors.black12, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(2.5.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("🇮🇳", style: TextStyle(fontSize: AppType.clampFontSize(16.sp))),
                      SizedBox(width: 2.w),
                      Text(
                        '+91',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppType.clampFontSize(14.sp),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: TextField(
                    focusNode: _phoneFocusNode,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    controller: _authC.phoneNumberLoginTextField.value,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => setState(() {}),
                    inputFormatters: [IndianMobileNumberFormatter()],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppType.clampFontSize(16.sp),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Mobile Number',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: AppType.clampFontSize(14.sp),
                        fontWeight: FontWeight.w400,
                        color: Colors.black38,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Premium Continue Button
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 6.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                gradient: isValidPhoneNumber
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA500),
                        ], // Richer gold/orange
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade300],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                boxShadow: isValidPhoneNumber
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFA500).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4.w),
                  onTapDown: isValidPhoneNumber ? _onTapDown : null,
                  onTapUp: isValidPhoneNumber ? _onTapUp : null,
                  onTapCancel: isValidPhoneNumber ? _onTapCancel : null,
                  onTap: isValidPhoneNumber && !_authC.isLoading.value
                      ? () async {
                          final phone =
                              _authC.phoneNumberLoginTextField.value.text;
                          final success = await _authC.requestOtp(phone);
                          if (success && mounted) {
                            setState(() => showOtp = true);
                            _otpC.startTimer();
                          }
                        }
                      : null,
                  child: Center(
                    child: _authC.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppType.clampFontSize(16.sp),
                              fontWeight: FontWeight.w700,
                              color: isValidPhoneNumber
                                  ? Colors.black
                                  : Colors.black54,
                              letterSpacing: 0.5,
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Base Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFEF200), Color(0xFFFFA000)],
              ),
            ),
          ),

          // Premium Background Decorative Elements (Subtle Depth)
          Positioned(
            top: -10.h,
            right: -10.w,
            child: Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: -15.w,
            child: Container(
              width: 35.h,
              height: 35.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: Listenable.merge([
              _logoController,
              _breathingController,
              _entranceController,
              _exitFadeController,
            ]),
            builder: (context, child) {
              final screenSize = MediaQuery.of(context).size;
              final t = Curves.easeInOut.transform(_logoController.value);
              final w =
                  screenSize.width * 0.70 +
                  (screenSize.width * 0.54 - screenSize.width * 0.70) * t;
              final h =
                  screenSize.height * 0.50 +
                  (screenSize.height * 0.10 - screenSize.height * 0.50) * t;
              final align = _logoAlignmentAnimation.value;

              final exitOpacity = _leavingToDashboard
                  ? _exitFadeOpacity.value
                  : 1.0;

              final baseLogo = SizedBox(
                width: w,
                height: h,
                child: Opacity(
                  opacity: _entranceOpacity.value * exitOpacity,
                  child: Transform.scale(
                    scale: _entranceScale.value,
                    child: Image.asset(CommonImages.logo1, fit: BoxFit.contain),
                  ),
                ),
              );

              final logo = _splashDone
                  ? ScaleTransition(scale: _breathingAnimation, child: baseLogo)
                  : baseLogo;

              return Align(alignment: align, child: logo);
            },
          ),

          SlideTransition(
            position: _formOffsetAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 82.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xffFFFDF9),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.w),
                  ),
                  // Premium top border highlight
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: showOtp ? _buildOtpContainer() : _buildLoginContainer(),
              ),
            ),
          ),

          if (_formSlideDone && !showOtp)
            Positioned(
              bottom: 4.h,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "By continuing, you agree to our",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppType.clampFontSize(11.sp),
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "T&C",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppType.clampFontSize(11.sp),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFA500),
                        ),
                      ),
                      Text(
                        "  &  ",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppType.clampFontSize(11.sp),
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "Privacy Policy",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppType.clampFontSize(11.sp),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFA500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

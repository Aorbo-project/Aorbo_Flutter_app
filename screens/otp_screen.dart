
import 'package:arobo_app/controller/otp_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sizer/sizer.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

import '../controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPScreen extends StatefulWidget {
  // final String phoneNumber;
  const OTPScreen({Key? key}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authC = Get.find<AuthController>();
  final FocusNode _pinFocusNode = FocusNode();

  // Initialize with a value instead of using late
  AnimationController? _animationController;
  Animation<double>? _shakeAnimation;
  Animation<double>? _scaleAnimation;
  bool _isError = false;
  bool _isSuccess = false;
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Shake animation for error
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.elasticIn,
      ),
    )..addListener(() {
        setState(() {});
      });

    // Scale animation for success
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Cancel existing timer if any
    _errorTimer?.cancel();

    // Start new timer to hide message after 3 seconds
    _errorTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void validateOTP(String pin) async {
    if (!mounted) return;

    try {
      if (pin.length == 6) {
        setState(() {
          _isSuccess = true;
          _isError = false;
          _errorMessage = null;
        });

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: Get.find<OTPController>().verificationId.value,
            smsCode: pin);

        try {
          // First verify with Firebase
          await FirebaseAuth.instance.signInWithCredential(credential);

          // Get the ID token after successful verification
          await Get.find<AuthController>().getIdToken();

          // Get the token and verify with backend
          String firebaseToken = Get.find<AuthController>().idToken.value;
          bool verified = await Get.find<AuthController>()
              .verifyFirebaseToken(firebaseToken);

          if (!mounted) return;

          if (verified) {
            _authC.phoneNumberLoginTextField.value.dispose();
            // Use a single navigation call and remove previous screens
            Get.offAllNamed('/dashboard');
          } else {
            if (!mounted) return;
            setState(() {
              _isError = true;
              _isSuccess = false;
            });
            _showErrorMessage('Server verification failed. Please try again.');
          }
        } catch (error) {
          if (!mounted) return;
          setState(() {
            _isError = true;
            _isSuccess = false;
          });
          _showErrorMessage('Invalid OTP. Please try again.');
          if (mounted) {
            _authC.otpTextField.value.clear();
            _pinFocusNode.requestFocus();
          }
        }
      } else {
        if (!mounted) return;
        _showErrorMessage('Please enter complete OTP');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('Something went wrong. Please try again.');
    }
  }

  @override
  void deactivate() {
    _errorTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _authC.otpTextField.value.dispose();
    _pinFocusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 25.sp,
      height: 30.sp,
      textStyle: GoogleFonts.poppins(
        fontSize: FontSize.s14,
        fontWeight: FontWeight.w700,
        color: CommonColors.blackColor,
      ),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: CommonColors.transparent,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: CommonColors.blackColor.withValues(alpha: 0.4),
            blurRadius: 1.5.w,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: CommonColors.activeColor2),
      ),
    );

    return GetX<OTPController>(
        init: OTPController(),
        builder: (controller) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: CommonColors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Text(
                'Verify OTP',
                // textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.blackColor,
                ),
              ),
              iconTheme: const IconThemeData(color: CommonColors.blackColor),
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(CommonImages.otpBg),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    CommonColors.softLightCyan.withValues(alpha: 0.1),
                    BlendMode.darken,
                  ),
                ),
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [
                //     CommonColors.softLightCyan,
                //     CommonColors.darkCyan,
                //   ],
                // ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50.h,
                    child: Opacity(
                      opacity: 1,
                      child: Image.asset(
                        CommonImages.texture,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter Verification Code',
                                  // textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                Text(
                                  'sent to +91 ${_authC.phoneNumberLoginTextField.value.text}',
                                  // textScaler: const TextScaler.linear(1.0),
                                  style: GoogleFonts.poppins(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Transform.translate(
                                offset: _isError
                                    ? Offset(_shakeAnimation?.value ?? 0, 0)
                                    : Offset.zero,
                                child: Transform.scale(
                                  scale: _isSuccess
                                      ? _scaleAnimation?.value ?? 1.0
                                      : 1.0,
                                  child: Pinput(
                                    length: 6,
                                    controller: _authC.otpTextField.value,
                                    focusNode: _pinFocusNode,
                                    defaultPinTheme: defaultPinTheme,
                                    submittedPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    separatorBuilder: (index) =>
                                        SizedBox(width: 3.5.w),
                                    onCompleted: validateOTP,
                                    onChanged: (value) {
                                      if (_isError || _isSuccess) {
                                        setState(() {
                                          _isError = false;
                                          _isSuccess = false;
                                          _errorMessage = null;
                                        });
                                      }
                                    },
                                    cursor: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 9),
                                          width: 22,
                                          height: 1,
                                          color: CommonColors.blackColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  fontSize: FontSize.s9,
                                  color: CommonColors.red_B52424,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            SizedBox(height: 2.h),
                            Text(
                              '${controller.formatTime()}',
                              // textScaler: const TextScaler.linear(1.0),
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s17,
                                color: CommonColors.appYellowColor,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5.w,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            TextButton(
                              onPressed: controller.enableResend.value
                                  ? () => controller.resendOTP()
                                  : null,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    // if (!controller.enableResend.value)
                                    //   TextSpan(
                                    //     text: controller.formatTime(),
                                    //     style: TextStyle(
                                    //       color: CommonColors.whiteColor
                                    //           .withValues(alpha: 0.6),
                                    //       fontWeight: FontWeight.w500,
                                    //       fontSize: FontSize.s9,
                                    //     ),
                                    //   ),
                                    if (controller.enableResend.value)
                                      TextSpan(
                                        text: 'Resend code via SMS',
                                        style: TextStyle(
                                          color: CommonColors.whiteColor,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              CommonColors.whiteColor,
                                          fontSize: FontSize.s9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

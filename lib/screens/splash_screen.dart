import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/controller/otp_controller.dart';
import 'package:arobo_app/screens/update_version_screen.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/widgets/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../controller/auth_controller.dart';

class SplashWithLoginScreen extends StatefulWidget {
  const SplashWithLoginScreen({super.key});

  @override
  State<SplashWithLoginScreen> createState() => _SplashWithLoginScreenState();
}

class _SplashWithLoginScreenState extends State<SplashWithLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Alignment> _logoAlignmentAnimation;
  late Animation<double> _logoWidthAnimation;
  late Animation<double> _logoHeightAnimation;
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

  final AuthController _authC = Get.put(AuthController());


  // final TextEditingController _phoneController = TextEditingController();
  bool isValid = false;
  bool showOtp = false;
  bool _splashDone = false;
  bool _formSlideDone = false;

  Timer? _timer;

  // int _start = 45;
  late TextEditingController _otpController;

  @override
  // void initState() {
  //   super.initState();
  //
  //   _animationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 300),
  //   );
  //   _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
  //     CurvedAnimation(
  //       parent: _animationController,
  //       curve: Curves.elasticIn,
  //     ),
  //   )..addListener(() {
  //       setState(() {});
  //     });
  //   _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
  //     CurvedAnimation(
  //       parent: _animationController,
  //       curve: Curves.easeInOut,
  //     ),
  //   );
  //   // _phoneController.addListener(() {
  //   //   final value = _phoneController.text;
  //   //   final valid = RegExp(r'^\d{10}$').hasMatch(value);
  //   //   if (valid != isValid) {
  //   //     setState(() {
  //   //       isValid = valid;
  //   //     });
  //   //   }
  //   //   if (value.length == 10) {
  //   //     FocusScope.of(context).unfocus();
  //   //   }
  //   // });
  //
  //   _logoController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 1200),
  //   );
  //
  //   _logoAlignmentAnimation = AlignmentTween(
  //     begin: Alignment.center,
  //     end: const Alignment(0.0, -0.88),
  //   ).animate(CurvedAnimation(
  //     parent: _logoController,
  //     curve: Curves.easeInOut,
  //   ));
  //
  //   _logoWidthAnimation = Tween<double>(
  //     begin: 70.w,
  //     end: 46.w,
  //   ).animate(CurvedAnimation(
  //     parent: _logoController,
  //     curve: Curves.easeInOut,
  //   ));
  //
  //   _logoHeightAnimation = Tween<double>(
  //     begin: 50.h,
  //     end: 10.h,
  //   ).animate(CurvedAnimation(
  //     parent: _logoController,
  //     curve: Curves.easeInOut,
  //   ));
  //
  //   _formController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 800),
  //   );
  //
  //   _formOffsetAnimation = Tween<Offset>(
  //     begin: const Offset(0, 1),
  //     end: Offset.zero,
  //   ).animate(CurvedAnimation(
  //     parent: _formController,
  //     curve: Curves.easeOut,
  //   ));
  //
  //   _breathingController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 3000),
  //   )..repeat(reverse: true);
  //
  //   _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
  //     CurvedAnimation(
  //       parent: _breathingController,
  //       curve: Curves.easeInOut,
  //     ),
  //   );
  //
  //   Future.delayed(const Duration(milliseconds: 1800), () async {
  //     await _logoController.forward();
  //     setState(() => _splashDone = true);
  //
  //     _formController.forward().then((_) {
  //       setState(() => _formSlideDone = true);
  //     });
  //   });
  //
  // }
  @override
  void initState() {
    super.initState();
    _otpC = Get.put(OTPController());

    // Logo Animations
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAlignmentAnimation = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0.0, -0.88), // Your target alignment
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoWidthAnimation = Tween<double>(
      begin: 70.w, // Your initial width
      end: 46.w, // Your target width
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoHeightAnimation = Tween<double>(
      begin: 50.h, // Your initial height
      end: 10.h, // Your target height
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Form Slide Animation
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _formOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));

    // Breathing Animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true); // Starts repeating immediately

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Button Tap/Shake Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    )..addListener(() {
        if (mounted) {
          // Good practice to check mounted in listeners
          setState(() {});
        }
      });

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // OTP Text Field Controller
    _otpController =
        TextEditingController(); // Assuming this was for your Pinput

    // Phone Number Validation Listener (from your original commented code)
    // If you are managing phone number text in AuthController, this might look like:
    // _authC.phoneNumberLoginTextField.value.addListener(() {
    //   final value = _authC.phoneNumberLoginTextField.value.text;
    //   final valid = RegExp(r'^\d{10}$').hasMatch(value);
    //   if (valid != isValid) {
    //     if (mounted) {
    //       setState(() {
    //         isValid = valid;
    //       });
    //     }
    //   }
    //   if (value.length == 10 && _phoneFocusNode.hasFocus) { // Check focus
    //      _phoneFocusNode.unfocus(); // Or FocusScope.of(context).unfocus();
    //   }
    // });

    // --- Core Splash Logic & Login Check ---
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _splashDone = true;
        });

        // Ensure breathing animation continues or starts as intended
        // (it's already set to repeat, but a forward() ensures it's active if somehow paused)
        if (!_breathingController.isAnimating) {
          _breathingController.forward(); // Or .repeat(reverse: true)
        }

        // Delay slightly for UX before checking login status
        Future.delayed(const Duration(milliseconds: 300), () async {
          // Adjust delay as needed
          if (!mounted) return;

          final validateResponse = await _authC.validateVersion();

          // if(validateResponse?.updateAvailable == true){
          //   Get.offAll(() => UpdateVersionScreen(dataModel:validateResponse));
          // }
          // else if (CommonLogics.checkUserLogin() && validateResponse?.updateAvailable == false) {
          //   Get.offAllNamed('/dashboard');
          // } else {
          //   _startFormAnimation(); // Defined below, handles form slide up
          // }

          if (CommonLogics.checkUserLogin()) {
            Get.offAllNamed('/dashboard');
          } else {
            _startFormAnimation(); // Defined below, handles form slide up
          }
        });
      }
    });

    // Start the initial logo animation
    // (Your original code had a delay before this, you can keep a small one if desired)
    Future.delayed(const Duration(milliseconds: 200), () {
      // Optional: short delay
      if (mounted) {
        _logoController.forward();
      }
    });
  }

  void _startFormAnimation() {
    if (!mounted) return;
    // Ensure _formController is initialized (should be in initState)
    _formController.forward(); // Use _formController
    _formController.addStatusListener((status) {
      // Listen to _formController
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

  // void _onContinue() {
  //   if (isValid) {
  //     FocusScope.of(context).unfocus();
  //     setState(() {
  //       showOtp = true;
  //       _start = 45;
  //     });
  //     _startTimer();
  //   }
  // }
  //
  // void _resendOtp() {
  //   setState(() => _start = 45);
  //   _startTimer();
  // }

  Widget _buildOtpContainer() {
    bool isError = false;
    bool isSuccess = false;
    final defaultPinTheme = PinTheme(
      width: 25.sp,
      height: 40.sp,
      textStyle: GoogleFonts.poppins(
        fontSize: FontSize.s16,
        fontWeight: FontWeight.w700,
        color: CommonColors.blackColor,
      ),
      decoration: BoxDecoration(
        color: CommonColors.whiteColor,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(
          color: Colors.transparent,
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
    String? _errorMessage;

    void validateOTP(String pin) async {
      if (!mounted) return;

      try {
        if (pin.length == 6) {
          setState(() {
            isSuccess = true;
            isError = false;
            _errorMessage = null;
          });

          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _authC.verificationIdData.value, smsCode: pin);

          try {
            // First verify with Firebase
            await FirebaseAuth.instance.signInWithCredential(credential);

            // Get the ID token after successful verification
            await Get.find<AuthController>().getIdToken();

            // Get the token and verify with backend
            String firebaseToken = Get.find<AuthController>().idToken.value;
            bool verified = await Get.find<AuthController>().verifyFirebaseToken(firebaseToken);

            if (!mounted) return;

            if (verified) {
              _authC.phoneNumberLoginTextField.value.dispose();
              // Use a single navigation call and remove previous screens
              Get.offAllNamed('/dashboard');
            } else {
              if (!mounted) return;
              setState(() {
                isError = true;
                isSuccess = false;
              });
              CustomSnackBar.show(
                Get.context!,
                message: 'Server verification failed. Please try again.',
              );
            }
          } catch (error, s) {
            if (!mounted) return;
            setState(() {
              isError = true;
              isSuccess = false;
            });
            logger.e(error);
            logger.e(s);
            CustomSnackBar.show(Get.context!,
                message: 'Invalid OTP. Please try again.');
            if (mounted) {
              _authC.otpTextField.value.clear();
              _pinFocusNode.requestFocus();
            }
          }
        } else {
          if (!mounted) return;
          CustomSnackBar.show(Get.context!,
              message: 'Please enter complete OTP');
        }
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.show(Get.context!,
            message: 'Something went wrong. Please try again.');
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => showOtp = false),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.black),
              ),
              SizedBox(width: 5.w),
              Text(
                "Verify OTP",
                style: TextStyle(
                    fontSize: FontSize.s14,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter Verification Code",
                    style: TextStyle(
                        fontSize: FontSize.s14,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 1.h),
                Text(
                    "sent to ${_authC.formattedPhoneNumber(phoneNumber: _authC.phoneNumberLoginTextField.value.text)}",
                    style: TextStyle(
                        fontSize: FontSize.s12,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.center,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Transform.translate(
                offset: isError
                    ? Offset(_shakeAnimation?.value ?? 0, 0)
                    : Offset.zero,
                child: Transform.scale(
                  scale: isSuccess ? _scaleAnimation.value : 1.0,
                  child: Pinput(
                    length: 6,
                    controller: _authC.otpTextField.value,
                    focusNode: _pinFocusNode,
                    defaultPinTheme: defaultPinTheme,
                    submittedPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    separatorBuilder: (index) => SizedBox(width: 4.5.w),
                    onCompleted: validateOTP,
                    onChanged: (value) {
                      if (isError || isSuccess) {
                        setState(() {
                          isError = false;
                          isSuccess = false;
                          _errorMessage = null;
                        });
                      }
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
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
          ),
          SizedBox(height: 4.h),
          Obx(
            () => !_otpC.enableResend.value
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      _otpC.formatTime(),
                      // textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s14,
                        color: CommonColors.blackColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5.w,
                      ),
                    ),
                  )
                : Container(),
          ),
          // SizedBox(height: 3.h),
          Obx(() => Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed:
                      _otpC.enableResend.value ? () => _otpC.resendOTP() : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (_otpC.enableResend.value)
                          TextSpan(
                            text: 'Resend code via SMS',
                            style: TextStyle(
                              color: CommonColors.bluebac,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: CommonColors.whiteColor,
                              fontSize: FontSize.s9,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLoginContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 5.h, bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Trek,",
              style: GoogleFonts.sairaStencilOne(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          Text("just a",
              style: GoogleFonts.sairaStencilOne(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          Text("Click",
              style: GoogleFonts.sairaStencilOne(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          Text("Away !",
              style: GoogleFonts.sairaStencilOne(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          SizedBox(height: 4.h),
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            // child: Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 4.w),
            //   child: Row(
            //     children: [
            //       Text("+91",
            //           style: TextStyle(
            //               fontSize: 12.sp,
            //               fontWeight: FontWeight.w500,
            //               color: Colors.black)),
            //       SizedBox(width: 2.w),
            //       Expanded(
            //         child: TextField(
            //           controller: _phoneController,
            //           keyboardType: TextInputType.number,
            //           maxLength: 10,
            //           onChanged: _onPhoneChanged,
            //           style: TextStyle(
            //             fontSize: 12.sp,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.black,
            //           ),
            //           decoration: InputDecoration(
            //             counterText: "",
            //             border: InputBorder.none,
            //             hintText: "Enter your Mobile Number",
            //             hintStyle: TextStyle(
            //               fontSize: 10.sp,
            //               color: const Color(0xff9D9D9D),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            child: Container(
              decoration: BoxDecoration(
                color: CommonColors.whiteColor,
                borderRadius: BorderRadius.circular(4.h),
                boxShadow: [
                  BoxShadow(
                    color: CommonColors.blackColor.withValues(alpha: 0.1),
                    blurRadius: 1.h,
                    offset: Offset(0, 0.5.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Text(
                    '+91',
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      child: TextField(
                        focusNode: _phoneFocusNode,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: _authC.phoneNumberLoginTextField.value,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {});
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: TextStyle(fontSize: FontSize.s10),
                        decoration: InputDecoration(
                          hintText: 'Enter your Mobile Number',
                          hintStyle: TextStyle(
                            color: CommonColors.greyColor,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Obx(() => GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: CommonButton(
                    text:
                        _authC.isLoading.value ? 'Please wait...' : 'Continue',
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w600,
                    height: 6.h,
                    onPressed: () {
                      if (isValidPhoneNumber) {
                        _authC.sendCode(
                            phoneNumber:
                                _authC.phoneNumberLoginTextField.value.text);
                        setState(() {
                          showOtp = true;
                          _otpC.startTimer();
                        });
                      } else {
                        CustomSnackBar.show(
                          context,
                          message:
                              "Please enter a valid 10-digit mobile number",
                        );
                      }
                    },
                    gradient: isValidPhoneNumber
                        ? const LinearGradient(
                            colors: [
                              CommonColors.appYellowColor,
                              CommonColors.appYellowColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : CommonColors.disableBtnGradient,
                    textColor: isValidPhoneNumber
                        ? CommonColors.blackColor
                        : CommonColors.whiteColor,
                  ),
                ),
              )),
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
          AnimatedBuilder(
            animation:
                Listenable.merge([_logoController, _breathingController]),
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
          //       if (CommonLogics.checkUserLogin()) {
//         Get.offNamed('/dashboard');
//       } else {
//         Get.offNamed('/login');
//       }
          SlideTransition(
            position: _formOffsetAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 85.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: Color(0xffFFFDF9),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.w)),
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
                    style: TextStyle(
                      fontSize: FontSize.s10,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "T&C",
                        style: TextStyle(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                          color: Colors.lightBlue,
                        ),
                      ),
                      Text(
                        "  &  ",
                        style: TextStyle(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: FontSize.s9,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                          color: Colors.lightBlue,
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

class CustomOtpInput extends StatefulWidget {
  final Function(String) onChanged;

  const CustomOtpInput({super.key, required this.onChanged});

  @override
  State<CustomOtpInput> createState() => _CustomOtpInputState();
}

class _CustomOtpInputState extends State<CustomOtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 12.w,
          height: 7.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }
}

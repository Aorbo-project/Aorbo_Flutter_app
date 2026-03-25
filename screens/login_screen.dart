
import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/common_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_touch_ripple/flutter_touch_ripple.dart';

import '../utils/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final AuthController _authC = Get.put(AuthController(), permanent: true);

  final FocusNode _phoneFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isValidPhoneNumber => _authC.isPhoneValid.value;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animationController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.loginbg,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(CommonImages.bgLogin),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              CommonColors.loginbg.withValues(alpha: 0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Your Trek,\n',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s19,
                                fontWeight: FontWeight.w700,
                                color: CommonColors.blackColor,
                              ),
                            ),
                            TextSpan(
                              text: 'just a\n',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s19,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.whiteColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Click\n',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s19,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.whiteColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Away !',
                              style: GoogleFonts.poppins(
                                fontSize: FontSize.s19,
                                fontWeight: FontWeight.w700,
                                color: CommonColors.appYellowColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: CommonColors.whiteColor,
                              borderRadius: BorderRadius.circular(4.h),
                              boxShadow: [
                                BoxShadow(
                                  color: CommonColors.blackColor
                                      .withValues(alpha: 0.1),
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
                                    fontSize: FontSize.s12,
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
                                      controller: _authC
                                          .phoneNumberLoginTextField.value,
                                      keyboardType: TextInputType.phone,
                                      onChanged: (value) {
                                        _authC.isPhoneValid.value =
                                            value.length == 10;
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
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.h),
                              child: TouchRipple(
                                rippleColor: CommonColors.blackColor
                                    .withValues(alpha: 0.1),
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(_phoneFocusNode);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CommonColors.transparent,
                                    borderRadius: BorderRadius.circular(4.h),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Obx(() => GestureDetector(
                            onTapDown: _onTapDown,
                            onTapUp: _onTapUp,
                            onTapCancel: _onTapCancel,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: CommonButton(
                                text: _authC.isLoading.value
                                    ? 'Please wait...'
                                    : 'Continue',
                                fontSize: FontSize.s14,
                                fontWeight: FontWeight.w600,
                                height: 6.h,
                                onPressed: () {
                                  if (isValidPhoneNumber) {
                                    _authC.sendCode(
                                        phoneNumber: _authC
                                            .phoneNumberLoginTextField
                                            .value
                                            .text);
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
                      const Spacer(),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 3.h,
                            top: 3.h,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'By continuing , You agree to our',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: CommonColors.whiteColor,
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'T&C | Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: CommonColors.appYellowColor,
                                    fontSize: FontSize.s9,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

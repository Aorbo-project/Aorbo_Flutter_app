import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/controller/otp_controller.dart';
import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/phone_input_formatter.dart';
import 'package:arobo_app/screens/update_version_screen.dart';
import 'package:arobo_app/models/auth/validate_version_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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

// ── Auth (login + OTP) design tokens ─────────────────────────────────────
class _Auth {
  static const ink = Color(0xFF17181C);
  static const muted = Color(0xFF6B7280);
  static const faint = Color(0xFF9AA1AC);
  static const brand = Color(0xFFFF9500); // primary orange
  static const brandDeep = Color(0xFFF57C00);
  static const gold = Color(0xFFFFC400);
  static const fieldBg = Color(0xFFF4F5F7);
  static const fieldBorder = Color(0xFFE4E7EC);
  static const danger = Color(0xFFE5484D);
  static const card = Color(0xFFFFFFFF);

  static TextStyle t(
    double size, {
    FontWeight w = FontWeight.w400,
    Color color = ink,
    double? height,
    double? spacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: AppType.clampFontSize(size),
        fontWeight: w,
        color: color,
        height: height,
        letterSpacing: spacing,
      );
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

  // Bootstrap (Firebase/prefs/repo) + version + session checks, kicked off in
  // initState so they run IN PARALLEL with the logo animation instead of
  // starting only after the logo has finished landing (~1.1s wasted before).
  Future<void>? _entryPrep;
  ValidateDataModel? _validateResponse;
  bool _prepLoggedIn = false;
  bool _prepSessionValid = false;

  Timer? _timer;
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpC = Get.put(OTPController());

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
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
      duration: const Duration(milliseconds: 300),
      // Start a touch in so frame 1 already shows a faint logo — no more
      // "blank yellow for ~1s" before anything appears.
      value: 0.12,
    );
    _entranceOpacity = Tween<double>(begin: 0.28, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _entranceScale = Tween<double>(begin: 0.72, end: 1.0).animate(
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
        _logoController.forward();
      }
    });

    // Repaint the phone field so its border reflects focus state.
    _phoneFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    // Boot + version/session checks run NOW, in parallel with the animation.
    _entryPrep = _runEntryPrep();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  /// Firebase/prefs/repo bootstrap, then the version check, then (if logged
  /// in) the session check. Kept in the SAME ORDER as the original flow —
  /// `validateVersion` primes Repository/Dio state that `validateSession`
  /// relies on, so these must not be parallelised. The win here is that the
  /// whole chain runs alongside the logo animation instead of only after it.
  /// Result is stashed in fields, consumed by [_proceedAfterLogoLanded].
  Future<void> _runEntryPrep() async {
    try {
      await appBootstrapFuture;
      _validateResponse = await _authC.validateVersion();
      _prepLoggedIn = CommonLogics.checkUserLogin();
      if (_prepLoggedIn) {
        _prepSessionValid = await _authC.validateSession();
      }
    } catch (_) {
      // Never let a failed check strand the user on the splash — the
      // decision logic falls through to the login form.
      _prepSessionValid = false;
    }
  }

  Future<void> _proceedAfterLogoLanded() async {
    if (!mounted) return;
    // The checks were kicked off in initState — by now they're usually
    // already done; await only covers a slow network.
    await (_entryPrep ?? Future.value());
    if (!mounted) return;

    if (_validateResponse?.updateRequired == true) {
      Get.offAll(() => UpdateVersionScreen(dataModel: _validateResponse));
      return;
    }

    if (_prepLoggedIn) {
      if (_prepSessionValid) {
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
      height: 6.6.h,
      textStyle: _Auth.t(19, w: FontWeight.w800),
      decoration: BoxDecoration(
        color: _Auth.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Auth.fieldBorder, width: 1.4),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: _Auth.brand, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: _Auth.brand.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: _Auth.brandDeep, width: 1.6),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: _Auth.danger.withValues(alpha: 0.06),
        border: Border.all(color: _Auth.danger, width: 1.6),
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
            SizedBox(height: 5.h),
            GestureDetector(
              onTap: () {
                _authC.otpTextField.value.clear();
                setState(() => showOtp = false);
              },
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: _Auth.fieldBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: _Auth.fieldBorder),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: _Auth.ink, size: 19),
              ),
            ),
            SizedBox(height: 3.h),

            Text('Verify your number',
                style: _Auth.t(22, w: FontWeight.w800, spacing: -0.4)),
            SizedBox(height: 0.8.h),
            Text.rich(
              TextSpan(
                text: 'Enter the 6-digit code sent to  ',
                style: _Auth.t(12.5, color: _Auth.muted, height: 1.45),
                children: [
                  TextSpan(
                    text:
                        '+91 ${_authC.phoneNumberLoginTextField.value.text}',
                    style: _Auth.t(12.5,
                        w: FontWeight.w700, color: _Auth.ink),
                  ),
                  TextSpan(
                    text: '   Edit',
                    style: _Auth.t(12.5,
                        w: FontWeight.w700, color: _Auth.brand),
                    recognizer: (TapGestureRecognizer()
                      ..onTap = () {
                        _authC.otpTextField.value.clear();
                        setState(() => showOtp = false);
                      }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.5.h),

            Center(
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
                    autofocus: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    forceErrorState: isError,
                    separatorBuilder: (_) => SizedBox(width: 2.2.w),
                    onCompleted: validateOTP,
                    onChanged: (_) {
                      if (isError) setState(() => isError = false);
                    },
                    cursor: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: 18,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: _Auth.brand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),

            Center(
              child: Obx(
                () => _otpC.enableResend.value
                    ? GestureDetector(
                        onTap: () {
                          _otpC.resendOTP();
                          _authC.otpTextField.value.clear();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded,
                                size: 16, color: _Auth.brand),
                            SizedBox(width: 1.5.w),
                            Text('Resend code',
                                style: _Auth.t(13,
                                    w: FontWeight.w700, color: _Auth.brand)),
                          ],
                        ),
                      )
                    : Text.rich(
                        TextSpan(
                          text: 'Resend code in  ',
                          style: _Auth.t(12.5, color: _Auth.faint),
                          children: [
                            TextSpan(
                              text: _otpC.formatTime(),
                              style: _Auth.t(12.5,
                                  w: FontWeight.w700, color: _Auth.muted),
                            ),
                          ],
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
    final phoneOk = isValidPhoneNumber;
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 5.h, bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── grabber
          Center(
            child: Container(
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(
                color: _Auth.fieldBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: 4.h),

          Text('Sign in to Aorbo',
              style: _Auth.t(22, w: FontWeight.w800, spacing: -0.4)),
          SizedBox(height: 0.8.h),
          Text(
            "Enter your mobile number — we'll text you a\n6-digit code to verify it.",
            style: _Auth.t(12.5, color: _Auth.muted, height: 1.45),
          ),
          SizedBox(height: 4.h),

          Text('MOBILE NUMBER',
              style: _Auth.t(9.5,
                  w: FontWeight.w700, color: _Auth.faint, spacing: 1.2)),
          SizedBox(height: 1.h),

          // ── phone field
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 7.2.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: _Auth.fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _phoneFocusNode.hasFocus
                    ? _Auth.brand
                    : _Auth.fieldBorder,
                width: _phoneFocusNode.hasFocus ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Text('🇮🇳',
                    style: TextStyle(fontSize: AppType.clampFontSize(15.sp))),
                SizedBox(width: 2.5.w),
                Text('+91', style: _Auth.t(15, w: FontWeight.w700)),
                SizedBox(width: 3.w),
                Container(width: 1, height: 3.2.h, color: _Auth.fieldBorder),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextField(
                    focusNode: _phoneFocusNode,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    controller: _authC.phoneNumberLoginTextField.value,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [IndianMobileNumberFormatter()],
                    style: _Auth.t(16, w: FontWeight.w700, spacing: 0.5),
                    cursorColor: _Auth.brand,
                    decoration: InputDecoration(
                      hintText: '00000 00000',
                      hintStyle:
                          _Auth.t(15, w: FontWeight.w500, color: _Auth.faint),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (phoneOk)
                  const Icon(Icons.check_circle_rounded,
                      color: _Auth.brand, size: 20),
              ],
            ),
          ),
          SizedBox(height: 1.4.h),

          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 13, color: _Auth.faint),
              SizedBox(width: 1.5.w),
              Text('Your number stays private. No spam, ever.',
                  style: _Auth.t(10.5, color: _Auth.faint)),
            ],
          ),
          SizedBox(height: 3.5.h),

          // ── continue button
          Obx(() {
            final loading = _authC.isLoading.value;
            final enabled = phoneOk && !loading;
            return GestureDetector(
              onTapDown: enabled ? _onTapDown : null,
              onTapUp: enabled ? _onTapUp : null,
              onTapCancel: enabled ? _onTapCancel : null,
              onTap: enabled
                  ? () async {
                      FocusScope.of(context).unfocus();
                      final phone =
                          _authC.phoneNumberLoginTextField.value.text;
                      final success = await _authC.requestOtp(phone);
                      if (success && mounted) {
                        setState(() => showOtp = true);
                        _otpC.startTimer();
                      }
                    }
                  : null,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: double.infinity,
                  height: 7.2.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: phoneOk
                        ? const LinearGradient(
                            colors: [_Auth.gold, _Auth.brand])
                        : null,
                    color: phoneOk ? null : _Auth.fieldBorder,
                    boxShadow: phoneOk
                        ? [
                            BoxShadow(
                              color: _Auth.brand.withValues(alpha: 0.34),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Continue',
                                  style: _Auth.t(15.5,
                                      w: FontWeight.w800,
                                      color: phoneOk
                                          ? Colors.white
                                          : _Auth.faint,
                                      spacing: 0.3)),
                              SizedBox(width: 2.w),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 18,
                                  color:
                                      phoneOk ? Colors.white : _Auth.faint),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }),
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
                padding: EdgeInsets.symmetric(horizontal: 6.5.w),
                decoration: BoxDecoration(
                  color: _Auth.card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 34,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: showOtp ? _buildOtpContainer() : _buildLoginContainer(),
              ),
            ),
          ),

          if (_formSlideDone && !showOtp)
            Positioned(
              bottom: 3.2.h,
              left: 8.w,
              right: 8.w,
              child: Text.rich(
                TextSpan(
                  text: 'By continuing you agree to our ',
                  style: _Auth.t(10.5, color: _Auth.faint, height: 1.4),
                  children: [
                    TextSpan(
                      text: 'Terms',
                      style: _Auth.t(10.5,
                          w: FontWeight.w700, color: _Auth.brand),
                    ),
                    TextSpan(text: ' & ', style: _Auth.t(10.5, color: _Auth.faint)),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: _Auth.t(10.5,
                          w: FontWeight.w700, color: _Auth.brand),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

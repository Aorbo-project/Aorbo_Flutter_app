import 'package:arobo_app/controller/auth_controller.dart';
import 'package:arobo_app/controller/otp_controller.dart';
import 'package:arobo_app/main.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/common_images.dart';
import 'package:arobo_app/utils/common_logics.dart';
import 'package:arobo_app/utils/custom_snackbar.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:arobo_app/utils/phone_input_formatter.dart';
import 'package:arobo_app/screens/update_version_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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
  // Plays once, before _logoController, so the logo grows into place from
  // nothing instead of just appearing already at full "resting" size. Kept
  // as its own controller (rather than folded into _logoController) so the
  // grow-in and the shrink-to-top move stay two clearly sequenced beats
  // instead of one animation doing double duty.
  late AnimationController _entranceController;
  late Animation<double> _entranceOpacity;
  late Animation<double> _entranceScale;
  // Fades the logo out over 160ms when leaving for /dashboard, replacing
  // an instant SizedBox.shrink() cut (see _goToDashboard). Short enough to
  // finish before the incoming dashboard's own header logo becomes visible
  // through Get's Transition.fade (Flutter's FadeUpwardsPageTransitionsBuilder
  // — the splash stays static underneath while dashboard slides up + fades
  // in over it, so this can't just be left frozen-and-visible: confirmed via
  // GetX 4.7.3 source, get_transition_mixin.dart — the dev's original
  // "hiding it outright" note in _logoAlignmentAnimation's comment above was
  // solving that exact double-logo clash), but the fade itself removes the
  // jarring instant-pop that a WhatsApp screen recording caught on 2026-08-27.
  late AnimationController _exitFadeController;
  late Animation<double> _exitFadeOpacity;
  // Logo width/height are deliberately NOT Tweens built once in initState.
  // They used to be (via Sizer's .w/.h), but on a slower device initState()
  // can run before the platform delivers real window metrics — Sizer's
  // global state was still zero at that exact moment, so the Tween baked in
  // 0.0 forever (confirmed via on-device debug logging: w=0.0 h=0.0). Now
  // computed fresh every frame from MediaQuery in the builder below, so
  // it's always correct regardless of that timing.
  late AnimationController _formController;
  late Animation<Offset> _formOffsetAnimation;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  // Drives the short staggered fade+slide-in for each step's inner
  // content (heading, field(s), button) once that step is showing — kept
  // separate from _formController (which only slides the whole panel) so
  // panel-slide and content-choreography can be reasoned about
  // independently. One controller PER step (not shared) — AnimatedSwitcher
  // keeps the outgoing step's subtree mounted for the crossfade duration,
  // and a shared controller reset via forward(from: 0) for the incoming
  // step would also re-trigger the outgoing step's still-listening
  // _staggerItem widgets.
  late AnimationController _loginStaggerController;
  late AnimationController _otpStaggerController;
  // Dedicated controller for the OTP-error shake — kept separate from
  // _animationController (button tap-scale) so a wrong-OTP shake can
  // never also nudge the Continue button's scale via a shared controller.
  late AnimationController _otpShakeController;
  late Animation<double> _otpShakeAnimation;
  late final OTPController _otpC;
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _referralFocusNode = FocusNode();
  bool _showReferralField = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final AuthController _authC = Get.put(AuthController(), permanent: true);

  // final TextEditingController _phoneController = TextEditingController();
  bool isValid = false;
  bool showOtp = false;
  bool _splashDone = false;
  bool _formSlideDone = false;
  // Set right before navigating to /dashboard so the shimmer/breathing
  // animations freeze on a static frame before the fade transition starts —
  // otherwise the fade blends two actively-moving screens together and
  // reads as a glitch instead of a smooth crossfade.
  bool _leavingToDashboard = false;

  // Drives OtpSuccessOverlay (see widgets/otp_success_overlay.dart) for the
  // inline OTP form below. Class-level (not local to _buildOtpContainer)
  // because that method is rebuilt fresh on every setState — a local flag
  // here would never survive the rebuild it's meant to trigger.
  bool _showOtpSuccessOverlay = false;

  // Same rebuild-survival requirement as _showOtpSuccessOverlay above —
  // these used to be local variables inside _buildOtpContainer() and were
  // silently discarded every rebuild, so a wrong OTP never actually
  // reached the screen as a red/shake error state.
  bool _otpIsError = false;
  String? _otpErrorMessage;

  Timer? _timer;
  // Shown only if the post-landing bootstrap/version/session checks are
  // still pending after a short grace period — see _proceedAfterLogoLanded.
  Timer? _bootHintTimer;
  bool _showBootHint = false;

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

    // Logo Animations — 700ms was overcorrecting on "don't make it feel
    // laggy": rapid-fire motion with no hold time reads as broken/glitchy
    // to the eye even when every frame renders correctly. 950ms was the
    // middle ground back when this was the only beat in the sequence.
    // Trimmed to 650ms as part of the full launch->login timing pass —
    // total fixed time from launch to an interactive login form was 2.9s,
    // past Android's ~2.5s "did it freeze?" threshold; still slow enough
    // to read as deliberate motion once played alongside the shorter
    // entrance/hold beats below.
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Moves to near the top — required so the logo stays visible ABOVE
    // the login form, which slides up and covers the bottom 85% of the
    // screen. (Briefly tried keeping this centered to avoid overlapping
    // dashboard's header logo during the fade, but that hid the logo
    // behind the login form entirely — much worse. The fade-overlap is
    // instead solved by hiding the logo outright right before navigating;
    // see _leavingToDashboard in the builder below.)
    _logoAlignmentAnimation =
        AlignmentTween(
          begin: Alignment.center,
          end: const Alignment(0.0, -0.88),
        ).animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
        );

    // Entrance (grow-in) — plays first. Fades in while scaling up from
    // small; easeOutBack gives it a slight overshoot past 1.0 before
    // settling, so it reads as one landing motion rather than a static pop.
    // Opacity finishes at 60% of the duration so the logo is already fully
    // visible while the scale is still settling into place. Trimmed from
    // 550ms as part of the launch->login timing pass — see the
    // _logoController comment above for the total-time context.
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

    // Exit fade — see the field comment above for why this replaces an
    // instant hide.
    _exitFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _exitFadeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitFadeController, curve: Curves.easeOut),
    );

    // Form Slide Animation — trimmed from 800ms as part of the
    // launch->login timing pass (see _logoController comment above).
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _formOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));

    // Breathing Animation — started later, once the logo has landed (see
    // the _logoController status listener below), so the cycle begins
    // fresh at the moment it first becomes visible in build() (gated on
    // _splashDone) instead of ticking silently underneath the entrance
    // and already being mid-cycle when it appears.
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Button Tap Animation Controller — scale-down feedback on the
    // Continue button only. The OTP-error shake has its own dedicated
    // controller (_otpShakeController, below) so the two never share
    // state.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Content stagger — short fade+translate-in for each step's inner
    // elements. Separate controllers (see field comment above) so the
    // Login and OTP steps never share animation state during the
    // AnimatedSwitcher crossfade.
    _loginStaggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _otpStaggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );

    // OTP error shake — a short, controlled, decaying shake (replacing
    // the old elastic-bounce curve). Amplitude decays 0 → -8 → 8 → -4 → 0
    // over the same 300ms window the old animation used.
    _otpShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _otpShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -8.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -8.0, end: 8.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 8.0, end: -4.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -4.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
    ]).animate(_otpShakeController);

    // Repaint the phone / referral fields so their borders reflect focus.
    _phoneFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _referralFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

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

        // Started here (not in initState) so the breathing cycle begins
        // fresh, in phase with the moment it first becomes visible in
        // build() — see the field comment above.
        _breathingController.repeat(reverse: true);

        // Was: Future.delayed(400ms) before starting the version/session
        // check — dropped as part of the launch->login timing pass (see
        // _logoController comment above). The shrink-to-top motion itself
        // already gives the logo its "landed" beat; a further fixed hold
        // here was pure added latency with no motion happening during it.
        _proceedAfterLogoLanded();
      }
    });

    // Once the logo has grown into place, give it a brief beat to register
    // as "landed" before it starts shrinking to the top — an instant cut
    // from grow-in straight into shrink would read as one confused motion.
    // Trimmed from 200ms as part of the launch->login timing pass.
    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _logoController.forward();
        });
      }
    });

    // repository.dart's 401 interceptor routes back to '/' with this flag
    // on a mid-session forced logout (session invalidated elsewhere, or a
    // dead refresh token) — as opposed to a real cold app start. Replaying
    // the full ~1s+ logo grow-in/shrink/breathing wind-up in that case
    // reads as the app hanging (the user was already past this moment
    // seconds ago); jump straight to the landed state and go to the login
    // form instead.
    final args = Get.arguments;
    final isForcedLogout = args is Map && args['forcedLogout'] == true;

    if (isForcedLogout) {
      _entranceController.value = 1.0;
      _logoController.value = 1.0;
      _splashDone = true;
      _breathingController.repeat(reverse: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.snackbar(
          'Signed out',
          'You were signed out — please log in again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4A3B00),
          colorText: Colors.white,
          margin: EdgeInsets.all(3.w),
          borderRadius: 14,
          duration: const Duration(seconds: 4),
        );
        _proceedAfterLogoLanded();
      });
      return;
    }

    // Start the logo animation on the very next frame — no artificial delay
    // before motion begins, so the first thing the user sees is already in
    // motion (matches the native splash's icon, which was already visible).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  // Runs once the shrink-to-top motion has completed. Split out of
  // initState's _logoController status listener so it can be called
  // directly (no artificial delay in front of it) — see the timing-pass
  // comment where it's invoked.
  Future<void> _proceedAfterLogoLanded() async {
    if (!mounted) return;

    // If the checks below take a moment (slow network, cold backend),
    // don't leave the screen looking finished with no response — fade in
    // a small status line after a short grace period. Cancelled the
    // instant any branch resolves (_goToDashboard / _startFormAnimation),
    // so the fast path never sees it.
    _bootHintTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showBootHint = true);
    });

    // main.dart's Firebase/Preferences/Repository init now runs
    // concurrently with this animation instead of blocking the first
    // frame — wait for it here, right before `sp`/the network stack
    // are actually needed. Normally already done by this point.
    await appBootstrapFuture;
    if (!mounted) return;

    final validateResponse = await _authC.validateVersion();

    // Hard block ONLY on update_required (below min_supported_version
    // — an explicit admin-set minimum). update_available alone means
    // "a newer version exists" and must never block anyone; that flag
    // used to be wired to this same block, which would have force-
    // blocked every user on every single release.
    if (validateResponse?.updateRequired == true) {
      _bootHintTimer?.cancel();
      Get.offAll(() => UpdateVersionScreen(dataModel: validateResponse));
      return;
    }

    if (CommonLogics.checkUserLogin()) {
      // Confirm the cached session is still accepted by the server
      // BEFORE committing to /dashboard — see validateSession's doc
      // comment for why (splash→dashboard→login flicker bug).
      final sessionValid = await _authC.validateSession();
      if (!mounted) return;

      if (sessionValid) {
        // Self-healing sync: catches a token that failed to register
        // on a previous run (flaky network, brief backend outage)
        // without waiting for this session's next login, which for a
        // completed profile may never happen again.
        _authC.registerFcmToken();
        _goToDashboard();
      } else {
        // Explicit server rejection — the cached flag lied, clear it
        // so the user lands cleanly on the login form instead of a
        // dashboard that would immediately bounce them back out.
        await sp!.clear();
        _startFormAnimation();
      }
    } else {
      _startFormAnimation(); // Defined below, handles form slide up
    }
  }

  // Freezes the splash on a static frame, then hands off to /dashboard via
  // dissolveToDashboard(): an opaque copy of this screen's yellow gradient
  // is held on top while the dashboard mounts + paints + runs its content
  // stagger hidden underneath, then that cover dissolves away (~300ms). No
  // white/washed flash — the old fade-in-over-still-opaque-splash approach
  // (Transition.fadeIn on the route) produced a measured ~60-90ms
  // desaturated flash on device. The route transition is now noTransition.
  //
  // Runs for BOTH cold-start auto-login and OTP-success: by the time this
  // is called the pin form has faded to nothing, so the visible background
  // is the same yellow gradient in both cases.
  void _goToDashboard() {
    _bootHintTimer?.cancel();
    if (!mounted) {
      Get.offAllNamed('/dashboard');
      return;
    }
    _breathingController.stop();
    setState(() => _leavingToDashboard = true);
    _exitFadeController.forward();
    _maybeShowReferralOutcome();
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

  // Persistent confirmation of the referral outcome the backend returned in
  // verify-otp. Fired as the dashboard mounts so it lands there, not on the
  // splash — the user never has to wonder whether the code "took". One-shot.
  void _maybeShowReferralOutcome() {
    final r = _authC.lastReferralResult.value;
    if (r == null) return;
    _authC.lastReferralResult.value = null;
    final ok = r.applied;
    Future.delayed(const Duration(milliseconds: 800), () {
      Get.snackbar(
        ok ? 'Referral applied 🎉' : 'Referral code',
        r.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor:
            ok ? const Color(0xFF1E8E3E) : const Color(0xFF4A3B00),
        colorText: Colors.white,
        margin: EdgeInsets.all(3.w),
        borderRadius: 14,
        duration: const Duration(seconds: 5),
        icon: Icon(
          ok ? Icons.verified_rounded : Icons.info_outline_rounded,
          color: Colors.white,
        ),
        shouldIconPulse: false,
      );
    });
  }

  void _startFormAnimation() {
    if (!mounted) return;
    _bootHintTimer?.cancel();
    if (_showBootHint) setState(() => _showBootHint = false);
    // Ensure _formController is initialized (should be in initState)
    _formController.forward(); // Use _formController
    _formController.addStatusListener((status) {
      // Listen to _formController
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        setState(() {
          _formSlideDone = true;
        });
        // Panel has settled — now choreograph its inner content in.
        _loginStaggerController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    if (_timer?.isActive == true) _timer?.cancel();
    _bootHintTimer?.cancel();
    _logoController.dispose();
    _entranceController.dispose();
    _exitFadeController.dispose();
    _formController.dispose();
    _breathingController.dispose();
    _animationController.dispose();
    _loginStaggerController.dispose();
    _otpStaggerController.dispose();
    _otpShakeController.dispose();
    _phoneFocusNode.dispose();
    _referralFocusNode.dispose();
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

  // One shared fade+translateY-in helper for the login/OTP panels' inner
  // content. `controller` is the calling step's own stagger controller
  // (_loginStaggerController / _otpStaggerController) — never shared
  // across steps, see the field comment above. `start`/`end` carve out
  // this item's slice of that controller's 0..1 timeline (Interval clamps
  // outside that slice), so a handful of these with staggered, overlapping
  // windows reads as one coordinated entrance rather than separate
  // animations. `dy: 0` for elements (like the OTP pin row) that must stay
  // put and only fade.
  Widget _staggerItem({
    required AnimationController controller,
    required double start,
    required double end,
    required Widget child,
    double dy = 8,
  }) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final t = Interval(start, end, curve: Curves.easeOut)
            .transform(controller.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * dy),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildOtpContainer() {
    // ── OTP cells — white keyline at rest, yellow glow when active, warm
    //    tint once filled, red on error.
    final defaultPinTheme = PinTheme(
      width: 12.5.w,
      height: 6.2.h,
      textStyle: AppType.style(FontSize.s18,
          w: FontWeight.w800, color: CommonColors.blackColor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC400).withValues(alpha: 0.55),
            blurRadius: 0,
            spreadRadius: 3,
          ),
        ],
      ),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFFFFBEA),
        border: Border.all(color: Colors.black, width: 1.6),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: AppType.style(FontSize.s18,
          w: FontWeight.w800, color: const Color(0xFFE5484D)),
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFFDECEC),
        border: Border.all(color: const Color(0xFFE5484D), width: 2),
      ),
    );

    void validateOTP(String pin) async {
      if (!mounted) return;

      try {
        if (pin.length == 6) {
          setState(() {
            _otpIsError = false;
            _otpErrorMessage = null;
          });

          final phone = _authC.phoneNumberLoginTextField.value.text;
          final referral = _authC.lastNumberIsExisting.value
              ? null
              : _authC.referralCodeTextField.value.text;
          final bool verified =
              await _authC.verifyOtp(phone, pin, referralCode: referral);

          if (!mounted) return;

          if (verified) {
            _authC.phoneNumberLoginTextField.value.clear();
            setState(() {
              _showOtpSuccessOverlay = true;
            });
            // _goToDashboard() now runs from OtpSuccessOverlay's onFinished
            // (see the build() method below) once the confirmation beat
            // plays out, instead of firing immediately here.
          } else {
            final backendMsg = _authC.otpErrorMessage.value.trim();
            setState(() {
              _otpIsError = true;
              _otpErrorMessage = backendMsg.isNotEmpty
                  ? backendMsg
                  : "That code didn't match. Check the SMS and try again.";
            });
            _otpShakeController.forward(from: 0);
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
          SizedBox(height: 2.h),
          _staggerItem(
            controller: _otpStaggerController,
            start: 0.0,
            end: 0.5,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _authC.clearReferralCode();
                    setState(() {
                      showOtp = false;
                      _showReferralField = false;
                    });
                    // Back to Login — replay its stagger so the step
                    // change is symmetric in both directions.
                    _loginStaggerController.forward(from: 0);
                  },
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.12),
                          width: 1.4),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.black, size: 20),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  "STEP 2 OF 2",
                  style: TextStyle(
                    fontSize: FontSize.s9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          _staggerItem(
            controller: _otpStaggerController,
            start: 0.1,
            end: 0.6,
            child: Padding(
              padding: EdgeInsets.only(left: 1.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verify your number",
                    style: GoogleFonts.sairaStencilOne(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  Text.rich(
                    TextSpan(
                      text: 'Enter the 6-digit code sent to  ',
                      style: AppType.style(FontSize.s11,
                          w: FontWeight.w400, color: Colors.black54, height: 1.4),
                      children: [
                        TextSpan(
                          text:
                              '+91 ${_authC.phoneNumberLoginTextField.value.text}',
                          style: AppType.style(FontSize.s11,
                              w: FontWeight.w700, color: Colors.black),
                        ),
                        TextSpan(
                          text: '   Edit',
                          style: AppType.style(FontSize.s11,
                              w: FontWeight.w700,
                              color: Colors.black,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _authC.otpTextField.value.clear();
                              _authC.clearReferralCode();
                              setState(() {
                                showOtp = false;
                                _showReferralField = false;
                              });
                              // Back to Login — replay its stagger so the
                              // step change is symmetric in both directions.
                              _loginStaggerController.forward(from: 0);
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Referral code — new signups only, above the OTP boxes so the
          // text keyboard never fights the OTP numeric keypad.
          _staggerItem(
            controller: _otpStaggerController,
            start: 0.2,
            end: 0.65,
            child: Padding(
              padding: EdgeInsets.only(left: 1.w, right: 1.w),
              child: _buildReferralSection(),
            ),
          ),

          SizedBox(height: 4.h),
          _staggerItem(
            controller: _otpStaggerController,
            start: 0.3,
            end: 0.75,
            dy: 0,
            child: Align(
              alignment: Alignment.center,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: AnimatedBuilder(
                  animation: _otpShakeController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_otpShakeAnimation.value, 0),
                    child: child,
                  ),
                  child: Pinput(
                    length: 6,
                    controller: _authC.otpTextField.value,
                    focusNode: _pinFocusNode,
                    defaultPinTheme: defaultPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    errorPinTheme: errorPinTheme,
                    forceErrorState: _otpIsError,
                    separatorBuilder: (index) => SizedBox(width: 3.5.w),
                    onCompleted: validateOTP,
                    onChanged: (value) {
                      if (_otpIsError) {
                        setState(() {
                          _otpIsError = false;
                          _otpErrorMessage = null;
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
          if (_otpIsError && _otpErrorMessage != null) ...[
            SizedBox(height: 1.6.h),
            Align(
              alignment: Alignment.center,
              child: Text(
                _otpErrorMessage!,
                textAlign: TextAlign.center,
                style: AppType.style(FontSize.s11,
                    w: FontWeight.w600, color: const Color(0xFFE5484D)),
              ),
            ),
          ],
          SizedBox(height: 4.h),
          _staggerItem(
            controller: _otpStaggerController,
            start: 0.45,
            end: 0.9,
            child: Column(
              children: [
                Obx(
                  () => !_otpC.enableResend.value
                      ? Align(
                          alignment: Alignment.center,
                          child: Text(
                            _otpC.formatTime(),
                            // textScaler: const TextScaler.linear(1.0),
                            style: AppType.style(FontSize.s14, w: FontWeight.w500, color: CommonColors.blackColor, letterSpacing: 0.5.w),
                          ),
                        )
                      : Container(),
                ),
                // SizedBox(height: 3.h),
                Obx(
                  () => Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _otpC.enableResend.value
                          ? () => _otpC.resendOTP()
                          : null,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildLoginContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 2.h, bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _staggerItem(
            controller: _loginStaggerController,
            start: 0.0,
            end: 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Trek,",
                  style: GoogleFonts.sairaStencilOne(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "just a",
                  style: GoogleFonts.sairaStencilOne(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Click",
                  style: GoogleFonts.sairaStencilOne(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Away !",
                  style: GoogleFonts.sairaStencilOne(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          _staggerItem(
            controller: _loginStaggerController,
            start: 0.15,
            end: 0.7,
            child: Padding(
              padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
              child: Text(
                'MOBILE NUMBER',
                style: TextStyle(
                  fontSize: FontSize.s9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),

          // ── Phone field — clean pill, focus glow, valid tick
          _staggerItem(
            controller: _loginStaggerController,
            start: 0.15,
            end: 0.7,
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            height: 6.6.h,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.6.h),
              border: Border.all(
                color: _phoneFocusNode.hasFocus
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.10),
                width: _phoneFocusNode.hasFocus ? 1.7 : 1.2,
              ),
              boxShadow: [
                if (_phoneFocusNode.hasFocus)
                  BoxShadow(
                    color: const Color(0xFFFFC400).withValues(alpha: 0.35),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  '+91',
                  textScaler: const TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 1.4,
                  height: 2.6.h,
                  color: Colors.black.withValues(alpha: 0.14),
                ),
                SizedBox(width: 3.5.w),
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
                      inputFormatters: [IndianMobileNumberFormatter()],
                      style: TextStyle(
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mobile number',
                        hintStyle: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          color: CommonColors.greyColor,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),
                AnimatedScale(
                  scale: isValidPhoneNumber ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC400),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.black, size: 15),
                  ),
                ),
              ],
            ),
          ),
          ),
          SizedBox(height: 3.h),

          // ── Continue button — gradient + sheen + arrow chip when ready,
          //    clean black outline when not
          _staggerItem(
            controller: _loginStaggerController,
            start: 0.3,
            end: 0.85,
            child: Obx(() {
            final ready = isValidPhoneNumber && !_authC.isLoading.value;
            final loading = _authC.isLoading.value;
            return GestureDetector(
              onTapDown: ready ? _onTapDown : null,
              onTapUp: ready ? _onTapUp : null,
              onTapCancel: ready ? _onTapCancel : null,
              onTap: () async {
                if (isValidPhoneNumber) {
                  final phone = _authC.phoneNumberLoginTextField.value.text;
                  final success = await _authC.requestOtp(phone);
                  if (success && mounted) {
                    setState(() {
                      showOtp = true;
                    });
                    _otpStaggerController.forward(from: 0);
                    _otpC.startTimer();
                  }
                } else {
                  CustomSnackBar.show(
                    context,
                    message: "Please enter a valid 10-digit mobile number",
                  );
                }
              },
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 6.6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.6.h),
                    color: ready ? null : Colors.transparent,
                    border: ready
                        ? null
                        : Border.all(color: Colors.black, width: 1.5),
                    gradient: ready
                        ? const LinearGradient(
                            colors: [Color(0xFFFFEE58), Color(0xFFFFC400)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: ready
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFC400)
                                  .withValues(alpha: 0.45),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // top sheen on the gradient
                      if (ready)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: 3.h,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(3.6.h)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.45),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: loading
                            ? SizedBox(
                                width: 2.6.h,
                                height: 2.6.h,
                                child: const CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2.4),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    textScaler: const TextScaler.linear(1.0),
                                    style: AppType.style(
                                      FontSize.s14,
                                      w: FontWeight.w800,
                                      color: ready
                                          ? Colors.black
                                          : Colors.black
                                              .withValues(alpha: 0.55),
                                    ),
                                  ),
                                  if (ready) ...[
                                    SizedBox(width: 3.w),
                                    Container(
                                      width: 3.4.h,
                                      height: 3.4.h,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          ),
        ],
      ),
    );
  }

  // ── Optional referral code (OTP screen only) ────────────────────────────
  // Shown only for a NEW number (AuthController.lastNumberIsExisting == false)
  // — a referral code is signup-only. Collapsed behind a link. As the user
  // types + taps Apply, validateReferralCode() checks it live so a typo is
  // caught before the OTP completes; the code then rides with verifyOtp() and
  // the backend applies it in the same request, with the real outcome shown
  // as a banner on the dashboard.
  static const _kReferralGreen = Color(0xFF1E8E3E);
  static const _kReferralRed = Color(0xFFD93025);

  Widget _buildReferralSection() {
    return Obx(() {
      if (_authC.lastNumberIsExisting.value) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: 3.h),
        child: !_showReferralField ? _referralLink() : _referralField(),
      );
    });
  }

  Widget _referralLink() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _showReferralField = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_referralFocusNode);
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard_rounded,
                size: FontSize.s14, color: Colors.black),
            SizedBox(width: 2.w),
            Text(
              'Have a referral code?',
              textScaler: const TextScaler.linear(1.0),
              style: AppType.style(
                FontSize.s11,
                w: FontWeight.w700,
                color: Colors.black,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _referralField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
          child: Text(
            'REFERRAL CODE (OPTIONAL)',
            textScaler: const TextScaler.linear(1.0),
            style: TextStyle(
              fontSize: FontSize.s9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ),
        _referralInputRow(),
        Obx(() {
          final msg = _authC.referralMessage.value;
          if (msg.isEmpty) return const SizedBox.shrink();
          final ok = _authC.referralIsValid.value;
          return Padding(
            padding: EdgeInsets.only(top: 1.h, left: 1.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  size: FontSize.s13,
                  color: ok ? _kReferralGreen : _kReferralRed,
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    msg,
                    textScaler: const TextScaler.linear(1.0),
                    style: TextStyle(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: ok ? _kReferralGreen : _kReferralRed,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _referralInputRow() {
    final focused = _referralFocusNode.hasFocus;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 6.6.h,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.6.h),
              border: Border.all(
                color: focused
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.10),
                width: focused ? 1.7 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: TextField(
                  focusNode: _referralFocusNode,
                  controller: _authC.referralCodeTextField.value,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (_authC.referralMessage.value.isNotEmpty) {
                      _authC.referralMessage.value = '';
                      _authC.referralIsValid.value = false;
                    }
                  },
                  onSubmitted: (_) => _authC.validateReferralCode(),
                  onTapOutside: (event) =>
                      FocusScope.of(context).unfocus(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      color: CommonColors.greyColor,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Obx(() {
          final checking = _authC.referralChecking.value;
          return GestureDetector(
            onTap: checking
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    _authC.validateReferralCode();
                  },
            child: Container(
              height: 6.6.h,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(3.6.h),
              ),
              alignment: Alignment.center,
              child: checking
                  ? SizedBox(
                      width: 2.2.h,
                      height: 2.2.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      'Apply',
                      textScaler: const TextScaler.linear(1.0),
                      style: AppType.style(
                        FontSize.s13,
                        w: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          );
        }),
      ],
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
                colors: [Color(0xFFFEF200), Color(0xFFFFA000)],
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
              // Computed fresh from MediaQuery every frame — see the field
              // comment above for why this can't be a Tween built once in
              // initState.
              final screenSize = MediaQuery.of(context).size;
              final t = Curves.easeInOut.transform(_logoController.value);
              // End width was 0.46 — at alignment (0, -0.88) that put the
              // shrunk logo's bottom edge ~3px past the login form's top
              // edge (form is 82% of screen height, so its top sits at 18%)
              // on a reference 390x844 screen, i.e. straddling the seam
              // instead of sitting cleanly on the gradient above it. 0.54
              // reads as noticeably more legible while the form's height
              // (see 82.h below) does the actual clearance work.
              final w = screenSize.width * 0.70 +
                  (screenSize.width * 0.54 - screenSize.width * 0.70) * t;
              final h = screenSize.height * 0.50 +
                  (screenSize.height * 0.10 - screenSize.height * 0.50) * t;
              final align = _logoAlignmentAnimation.value;

              // Was: `if (_leavingToDashboard) return const SizedBox.shrink();`
              // — an instant, single-frame disappearance, caught looking
              // dead/broken in a screen recording (2026-08-27). Multiplied
              // into the same Opacity as the entrance fade below instead,
              // so leaving dissolves the logo over 160ms rather than
              // popping it away.
              final exitOpacity =
                  _leavingToDashboard ? _exitFadeOpacity.value : 1.0;

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
          //       if (CommonLogics.checkUserLogin()) {
          //         Get.offNamed('/dashboard');
          //       } else {
          //         Get.offNamed('/login');
          //       }
          // Always mounted (not gated by an `if`) so AnimatedOpacity's
          // fade-out actually plays when _showBootHint flips back to
          // false — an `if` here would unmount it on the same frame,
          // before the 260ms fade could run. IgnorePointer since it's
          // non-interactive and may briefly overlap the incoming form
          // while fading out.
          Positioned(
            left: 0,
            right: 0,
            bottom: 6.h,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showBootHint ? 1 : 0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: Center(
                  child: Text(
                    'Checking your session…',
                    style: AppType.style(FontSize.s10,
                        w: FontWeight.w500, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
          SlideTransition(
            position: _formOffsetAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                // Was 85.h — that put this form's top edge right where the
                // shrunk logo's bottom edge lands (see the `w` comment
                // above), so the logo looked wedged into the seam instead
                // of sitting clear of it on the gradient. 82.h opens a
                // ~19px gap on a reference 390x844 screen without the
                // alignment/height above needing to change.
                height: 82.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: Color(0xffFFFDF9),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.w),
                  ),
                ),
                // Login <-> OTP step change — was a direct content swap
                // (hard cut). AnimatedSwitcher cross-fades the two, with
                // OTP content entering from the right and Login content
                // entering from the left (so the reverse/back transition
                // mirrors correctly too); the white panel above this
                // never moves, only its inner content.
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  // Default AnimatedSwitcher layout centers old/new children
                  // in its Stack — fine when both are the same height, but
                  // Login and OTP content are different heights, so each
                  // was centering independently and landing at a different
                  // vertical offset. Top-anchor both instead so the panel
                  // content always starts at the same place regardless of
                  // which step is showing.
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  transitionBuilder: (child, animation) {
                    final isOtp = child.key == const ValueKey('otp');
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(isOtp ? 0.06 : -0.06, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                          position: offsetAnimation, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(showOtp ? 'otp' : 'login'),
                    child: showOtp
                        ? _buildOtpContainer()
                        : _buildLoginContainer(),
                  ),
                ),
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
                    style: AppType.style(FontSize.s10, w: FontWeight.w400, color: Colors.black),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "T&C",
                        style: AppType.style(FontSize.s9, w: FontWeight.w400, color: Colors.lightBlue),
                      ),
                      Text(
                        "  &  ",
                        style: AppType.style(FontSize.s9, w: FontWeight.w400, color: Colors.black),
                      ),
                      Text(
                        "Privacy Policy",
                        style: AppType.style(FontSize.s9, w: FontWeight.w400, color: Colors.lightBlue),
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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
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
                color: Colors.black.withValues(alpha: 0.3),
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

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/screen_constants.dart';

/// Plays once OTP verification succeeds: dims and fades out [child] (the
/// pin entry UI), fades up a personalized "Welcome back" line over it,
/// holds, fades that back out, then calls [onFinished] — the caller
/// navigates from there so the destination route's own transition still
/// runs on top of this. Total duration is fixed at ~1.1s, in line with
/// 2026 auth-motion norms (fast, no bounce) rather than the old dead
/// scale-animation this replaces. Deliberately no blur — see the `_dim`
/// field comment for why animating one is too expensive here.
class OtpSuccessOverlay extends StatefulWidget {
  final Widget child;
  final bool play;
  final String? customerName;
  final bool isNewCustomer;
  final VoidCallback onFinished;

  const OtpSuccessOverlay({
    super.key,
    required this.child,
    required this.play,
    required this.onFinished,
    this.customerName,
    this.isNewCustomer = false,
  });

  @override
  State<OtpSuccessOverlay> createState() => _OtpSuccessOverlayState();
}

class _OtpSuccessOverlayState extends State<OtpSuccessOverlay>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1090);

  late final AnimationController _c;
  late final Animation<double> _dim;
  late final Animation<double> _childOpacity;
  late final Animation<double> _welcomeOpacity;
  late final Animation<double> _welcomeTranslateY;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _total);

    // Dim ramp: 0-300ms (~0.275 of total). Was blur+dim — the blur was
    // dropped (see class doc) since animating ImageFilter.blur forces a
    // full re-rasterize of `child` on every tick for the whole ~1.1s
    // (AnimatedBuilder rebuilds for the whole controller, and a freshly
    // constructed ImageFilter each frame reads as "changed" even once the
    // sigma value itself plateaus) — visibly janky in debug, real cost
    // even in release. The dim scrim + child fade below already carry
    // most of the "receding" read at a fraction of the render cost.
    const dimEnd = 0.275;
    _dim = Tween<double>(begin: 0, end: 0.32).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, dimEnd, curve: Curves.easeOut)),
    );
    // Pin content fades out in the last 80ms of the blur ramp (220-300ms).
    _childOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.202, dimEnd, curve: Curves.easeIn)),
    );

    // Welcome text: fade in 300-520ms, hold to 870ms, fade out to 1090ms.
    _welcomeOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 300),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 220),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 350),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 220),
    ]).animate(_c);
    _welcomeTranslateY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(6.0), weight: 300),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 220),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 350),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 220),
    ]).animate(_c);

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });

    if (widget.play) _c.forward();
  }

  @override
  void didUpdateWidget(covariant OtpSuccessOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String get _greeting {
    final name = widget.customerName?.trim();
    if (widget.isNewCustomer || name == null || name.isEmpty) {
      return 'Welcome to Aorbo!';
    }
    return 'Welcome back, ${name.split(' ').first}';
  }

  String get _avatarInitial {
    final name = widget.customerName?.trim();
    return (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'A';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Stack(
          children: [
            Opacity(
              opacity: _childOpacity.value,
              child: widget.child,
            ),
            if (_dim.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: Colors.black.withValues(alpha: _dim.value)),
                ),
              ),
            if (_welcomeOpacity.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, _welcomeTranslateY.value),
                      child: Opacity(
                        opacity: _welcomeOpacity.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: CommonColors.appYellowColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _avatarInitial,
                                style: AppType.style(FontSize.s18, w: FontWeight.w700, color: CommonColors.blackColor),
                              ),
                            ),
                            SizedBox(height: 1.2.h),
                            Text(
                              _greeting,
                              style: AppType.style(
                                FontSize.s15,
                                w: FontWeight.w700,
                                color: CommonColors.whiteColor,
                                shadows: const [Shadow(color: Colors.black45, blurRadius: 8)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Plays once OTP verification succeeds: fades [child] (the pin entry UI)
/// out while a faint wash of three soft color blobs blooms, holds briefly,
/// and dissolves — then calls [onFinished], which navigates from there so
/// the destination route's own transition still runs on top of this.
///
/// This replaced two earlier attempts, in order:
/// 1. A dead `_scaleAnimation` that was declared but never `.forward()`'d
///    (the original bug this widget exists to fix).
/// 2. A personalized "Welcome back" text treatment with an avatar circle and a
///    black dim scrim — dropped after real-device testing and design
///    review both rejected it: the scrim (even lightened) still read as
///    the vivid gradient flattening to grey, and text greetings kept
///    landing flat regardless of how the avatar/scrim were tuned. Design
///    direction moved to a text-free "confirmation moment" instead,
///    landing on this one.
///
/// Total duration is fixed at ~1.0s — intentionally short (design
/// feedback: "1-2 sec loppu chalu", not the ~2.9s some earlier passes
/// drifted toward). No `ImageFilter.blur` anywhere: the blobs get their
/// soft edge from `RadialGradient`'s built-in alpha falloff instead of an
/// actual blur pass — animating a real blur was the exact bug fixed in
/// pass 1 above (forces a full re-rasterize of `child` every frame for
/// the whole animation), so a from-scratch effect here can't reintroduce
/// it.
class OtpSuccessOverlay extends StatefulWidget {
  final Widget child;
  final bool play;
  final VoidCallback onFinished;

  const OtpSuccessOverlay({
    super.key,
    required this.child,
    required this.play,
    required this.onFinished,
  });

  @override
  State<OtpSuccessOverlay> createState() => _OtpSuccessOverlayState();
}

class _OtpSuccessOverlayState extends State<OtpSuccessOverlay>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 1000);

  late final AnimationController _c;
  late final Animation<double> _childOpacity;
  late final Animation<double> _auroraOpacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _total);

    // Pin content fades out over the same 250ms the blobs take to bloom
    // in, so one dissolves as the other arrives rather than the two
    // fighting for the same 250ms independently.
    _childOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)),
    );

    // Bloom in (0-250ms) -> hold (250-700ms) -> dissolve (700-1000ms).
    _auroraOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 250,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 450),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 300,
      ),
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

  // Alignment is fractional (-1..1) rather than fixed dp offsets because
  // this overlay wraps two differently-sized things depending on caller:
  // the full screen in otp_screen.dart, but only the bottom sheet-style
  // form panel in splash_screen.dart. Fractional alignment lands in
  // roughly the same relative spot in both.
  Widget _blob({required Alignment alignment, required double size, required Color color}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
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
            if (_auroraOpacity.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: _auroraOpacity.value,
                    child: Stack(
                      children: [
                        _blob(alignment: const Alignment(-0.7, -0.75), size: 45.w, color: const Color(0xFFFEF200)),
                        _blob(alignment: const Alignment(0.8, -0.35), size: 40.w, color: const Color(0xFFFFA000)),
                        _blob(alignment: const Alignment(-0.6, 0.85), size: 42.w, color: const Color(0xFF1F8A6E)),
                      ],
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

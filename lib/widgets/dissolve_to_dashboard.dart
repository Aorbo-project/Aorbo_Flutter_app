import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Navigates to `/dashboard` while an opaque [cover] sits on top, then
/// dissolves the cover away once the dashboard has had a couple of frames
/// to lay out and paint.
///
/// Fixes the splash→dashboard (and OTP-success→dashboard) white/washed
/// flash: the old handoff faded the incoming dashboard in over the still-
/// opaque splash gradient, and the dashboard's first 2-3 frames are just
/// its blank `#F5F8FF` Scaffold background — so you got a ~60-90ms
/// desaturated flash (measured on device). Here the dashboard mounts and
/// runs its `_FadeSlideIn` content stagger entirely BEHIND [cover]; the
/// reveal is then a clean fade of one opaque layer.
///
/// [cover] should visually match whatever is on screen when this is
/// called — the yellow splash gradient from SplashWithLoginScreen, a plain
/// `#F5F8FF` from the standalone OTP screen — so there is no jump before
/// the dissolve begins.
///
/// [context] must be a context under the app navigator's Overlay (any
/// screen's own `context` is). The overlay entry it inserts lives on the
/// navigator's OverlayState, not the route, so `Get.offAllNamed` below
/// can't tear it down.
void dissolveToDashboard(BuildContext context, {required Widget cover}) {
  // The nearest Overlay to any screen's context IS the app navigator's
  // shared OverlayState (routes are entries in it). Our entry goes there
  // too and outlives the route swap below.
  final OverlayState? overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    // Shouldn't happen from a real screen — but never hang the app over a
    // cosmetic transition.
    Get.offAllNamed('/dashboard');
    return;
  }

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _DissolveCover(
      cover: cover,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
  Get.offAllNamed('/dashboard');
}

class _DissolveCover extends StatefulWidget {
  final Widget cover;
  final VoidCallback onDone;
  const _DissolveCover({required this.cover, required this.onDone});

  @override
  State<_DissolveCover> createState() => _DissolveCoverState();
}

class _DissolveCoverState extends State<_DissolveCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fade = Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeOut),
  );
  bool _done = false;

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Give the dashboard under us a couple of layout/paint frames before
      // we start clearing.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) {
        _finish();
        return;
      }
      await _c.forward();
      _finish();
    });
    // Safety net: `forward()`'s future never completes if the app is
    // backgrounded mid-animation — don't leave the cover stuck.
    Future<void>.delayed(const Duration(milliseconds: 1200), _finish);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _fade,
        child: SizedBox.expand(child: widget.cover),
      ),
    );
  }
}

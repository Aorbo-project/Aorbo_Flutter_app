import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Dashboard-entrance gate ────────────────────────────────────────────────
// While a dissolve cover is up, the dashboard is mounted but hidden. Its
// staggered header entrance (_FadeSlideIn) must NOT run yet — if it does it
// finishes behind the cover and the reveal shows content caught mid-motion.
// The dashboard's entrance widgets call [whenDashboardVisible]; the cover
// releases them once it's ~mostly faded. Any non-dissolve arrival (bottom-nav
// tab switch, Get.until back to it) sees `_coverActive == false` and runs
// immediately.

bool _coverActive = false;
final List<VoidCallback> _waiters = <VoidCallback>[];

/// Runs [cb] now if no dissolve cover is up, otherwise once the current
/// cover has mostly cleared.
void whenDashboardVisible(VoidCallback cb) {
  if (!_coverActive) {
    cb();
  } else {
    _waiters.add(cb);
  }
}

void _releaseWaiters() {
  if (!_coverActive) return;
  _coverActive = false;
  final pending = List<VoidCallback>.of(_waiters);
  _waiters.clear();
  for (final cb in pending) {
    cb();
  }
}

/// Navigates to `/dashboard` while an opaque [cover] sits on top, then
/// dissolves the cover away once the dashboard has had a couple of frames
/// to lay out and paint.
///
/// Fixes the splash→dashboard (and OTP-success→dashboard) white/washed
/// flash: the old handoff faded the incoming dashboard in over the still-
/// opaque splash gradient, and the dashboard's first 2-3 frames are just
/// its blank `#F5F8FF` Scaffold background — a measured ~60-90ms
/// desaturated flash on device.
///
/// Sequence:
///   1. insert the [cover] overlay entry (opaque)
///   2. once it has actually painted (post-frame), THEN `Get.offAllNamed`
///      — so the route swap + the dashboard's blank first frames happen
///      entirely behind an already-opaque layer, no 1-frame race
///   3. hold ~60ms so the dashboard lays out, then fade the cover over
///      300ms (easeOut) and remove it
///
/// [cover] should visually match whatever is on screen when this is
/// called — the yellow splash gradient from SplashWithLoginScreen, plain
/// `#F5F8FF` from the standalone OTP screen — so there is no jump before
/// the dissolve begins.
///
/// [context] must be under the app navigator's Overlay (any screen's own
/// `context` is). The entry lives on that shared OverlayState, not the
/// route, so `Get.offAllNamed` can't tear it down.
void dissolveToDashboard(BuildContext context, {required Widget cover}) {
  final OverlayState? overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    // Shouldn't happen from a real screen — but never hang the app over a
    // cosmetic transition.
    Get.offAllNamed('/dashboard');
    return;
  }

  _coverActive = true;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _DissolveCover(
      cover: cover,
      onReady: () => Get.offAllNamed('/dashboard'),
      // Fired ~65% through the fade — the dashboard is visible enough that
      // its entrance animation reading as "starting now" looks right, and
      // the last of the fade overlaps the first stagger step.
      onMostlyClear: _releaseWaiters,
      onDone: () {
        _releaseWaiters(); // safety — in case onMostlyClear never fired
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _DissolveCover extends StatefulWidget {
  final Widget cover;

  /// Called on the first frame AFTER the cover has painted — the safe
  /// moment to swap the route underneath it.
  final VoidCallback onReady;

  /// Called once the fade is ~80% done (cover ~20% opacity).
  final VoidCallback onMostlyClear;
  final VoidCallback onDone;

  const _DissolveCover({
    required this.cover,
    required this.onReady,
    required this.onMostlyClear,
    required this.onDone,
  });

  @override
  State<_DissolveCover> createState() => _DissolveCoverState();
}

class _DissolveCoverState extends State<_DissolveCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _fade = Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeInOut),
  );
  bool _done = false;
  bool _mostlyClearFired = false;

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  void _onTick() {
    if (!_mostlyClearFired && _c.value >= 0.8) {
      _mostlyClearFired = true;
      widget.onMostlyClear();
    }
  }

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Cover has painted (opaque) — now it's safe to swap routes behind it.
      widget.onReady();
      // Let the dashboard mount + get a couple layout/paint frames in, still
      // hidden, before we start clearing.
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
    Future<void>.delayed(const Duration(milliseconds: 1400), _finish);
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

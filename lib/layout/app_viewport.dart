// The app's window, whatever the device does with it (Play Console, Oct 2026).
//
// Every screen is laid out for a phone held upright: fixed `sizer` percentages
// of the window, no reflow. Android 16 ignores "not resizable" and the portrait
// lock on screens >= 600 dp (tablets, foldables, desktop windows), and a phone
// can show the app in split-screen. A raw tablet / landscape / half-height
// window stretches or squeezes those layouts. So the app is always drawn on a
// phone-shaped canvas:
//
//   * phone, upright (320-500 dp wide, >= 560 dp tall): unchanged, edge to edge;
//   * wider (tablet, foldable, landscape): a phone-width column (max 500 dp),
//     full height, centred;
//   * very narrow or short (split-screen): drawn at the minimum phone size and
//     scaled down to fit - smaller, never broken.
//
// The canvas gets its own MediaQuery (size, system-bar insets, keyboard), so
// `sizer`, dialogs, sheets and toasts all see one consistent phone window.
// The portrait lock stays for phones only (a tablet may rotate; the canvas
// keeps the layout upright either way).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// How the app is drawn inside a window.
@immutable
class ViewportPlan {
  const ViewportPlan({required this.width, required this.height, required this.scale, required this.passThrough});

  /// Canvas size the screens lay out on (logical px).
  final double width;
  final double height;

  /// Canvas -> window scale (1 = actual size).
  final double scale;

  /// True on a normal phone window: the app is drawn exactly as before.
  final bool passThrough;

  @override
  String toString() => 'ViewportPlan(${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)} @ ${scale.toStringAsFixed(3)}${passThrough ? ', pass-through' : ''})';
}

/// Phone-shaped canvas bounds (logical px).
const double kViewportMinWidth = 320;
const double kViewportMaxWidth = 500;
const double kViewportMinHeight = 560;

/// Screens this wide on their SHORT side are "large" (Android's own threshold).
const double kLargeScreenShortestSide = 600;

/// Pure: the canvas for a window of [window] logical px.
ViewportPlan planViewport(
  Size window, {
  double minWidth = kViewportMinWidth,
  double maxWidth = kViewportMaxWidth,
  double minHeight = kViewportMinHeight,
}) {
  final w = window.width;
  final h = window.height;
  if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
    return ViewportPlan(width: w, height: h, scale: 1, passThrough: true);
  }
  // A phone held upright: exactly as before.
  if (w >= minWidth && w <= maxWidth && h >= minHeight) {
    return ViewportPlan(width: w, height: h, scale: 1, passThrough: true);
  }
  final canvasW = w.clamp(minWidth, maxWidth).toDouble();
  // Narrower than a phone: draw at phone width, scale down.
  var scale = w < minWidth ? w / minWidth : 1.0;
  var canvasH = h / scale;
  // Shorter than a phone: draw at phone height, scale down to fit.
  if (canvasH < minHeight) {
    canvasH = minHeight;
    scale = math.min(scale, h / minHeight);
  }
  scale = math.min(scale, w / canvasW);
  return ViewportPlan(width: canvasW, height: canvasH, scale: scale, passThrough: false);
}

/// Is the device's screen "large" (tablet / foldable / desktop window)?
bool isLargeScreen(Size screen) => screen.shortestSide >= kLargeScreenShortestSide;

/// Portrait lock on phones; free rotation on large screens (Android 16 ignores
/// the lock there anyway, and the canvas keeps every screen upright).
List<DeviceOrientation> orientationsFor(Size screen) =>
    isLargeScreen(screen) ? const <DeviceOrientation>[] : const [DeviceOrientation.portraitUp];

class AppViewport extends StatefulWidget {
  const AppViewport({super.key, required this.child, this.background = const Color(0xFFE9EDF0)});

  final Widget child;

  /// Colour around the canvas on a wide / scaled window.
  final Color background;

  @override
  State<AppViewport> createState() => _AppViewportState();
}

class _AppViewportState extends State<AppViewport> {
  bool? _large;

  // Re-applied when the screen class changes (a foldable opening / closing).
  void _applyOrientation(Size screen) {
    final large = isLargeScreen(screen);
    if (_large == large) return;
    _large = large;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations(orientationsFor(screen));
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryData.fromView(View.of(context));
    _applyOrientation(mq.size);
    return LayoutBuilder(
      builder: (context, constraints) {
        final plan = planViewport(Size(constraints.maxWidth, constraints.maxHeight));
        if (plan.passThrough) return widget.child;
        final s = plan.scale;
        // Insets in canvas units; side insets only matter when the canvas
        // touches that side (it is centred, so mostly it does not).
        final touchesSides = (plan.width * s - constraints.maxWidth).abs() < 0.5;
        EdgeInsets toCanvas(EdgeInsets e) => EdgeInsets.fromLTRB(
              touchesSides ? e.left / s : 0,
              e.top / s,
              touchesSides ? e.right / s : 0,
              e.bottom / s,
            );
        final canvas = MediaQuery(
          data: mq.copyWith(
            size: Size(plan.width, plan.height),
            padding: toCanvas(mq.padding),
            viewPadding: toCanvas(mq.viewPadding),
            viewInsets: toCanvas(mq.viewInsets),
            systemGestureInsets: toCanvas(mq.systemGestureInsets),
          ),
          child: SizedBox(width: plan.width, height: plan.height, child: widget.child),
        );
        return ColoredBox(
          color: widget.background,
          child: Center(
            child: SizedBox(
              width: plan.width * s,
              height: plan.height * s,
              child: s == 1 ? canvas : FittedBox(fit: BoxFit.contain, child: canvas),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:ui' show ImageFilter;

import 'package:arobo_app/controller/dashboard_controller.dart';
import 'package:arobo_app/theme/app_typography.dart';
import 'package:arobo_app/utils/common_colors.dart';
import 'package:arobo_app/utils/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

/// Floating GLASS navigation bar — 3D slab + extruded key selection.
///
/// Depth, front to back:
///  1. Content scrolls BEHIND the frosted-glass bar (extendBody).
///  2. The glass is a THICK SLAB: lit top edge, darkened bottom edge.
///  3. Dual float shadows (contact + ambient) hover the slab.
///  4. The selected pill is an EXTRUDED KEY: top-lit gradient, hard
///     dark side face, ambient shadow, warm brand-colored glow.
///  5. Pressing a tab DEPRESSES the key 2px into the glass.
///
/// Selection is the "bloom" morph: the pill condenses out of the icon's
/// own footprint; deselect reverses. Unselected slots show ONLY a
/// bigger muted icon.
///
/// OPTICAL CENTERING: the content column reserves a 16px label slot
/// BELOW the icon — so a bare (unselected) icon sits at the top of the
/// column, ~8px above the bar's true center. The content now shifts
/// down by that amount when bare and rises into place as the pill
/// blooms: the icon is optically centered in EVERY state.
///
/// Layout fixes carried over: bar height lives on the margin-bearing
/// Container (float margin not deducted); label sits in a fixed 16px
/// FittedBox slot (.sp text double-scales on wide/high-text-scale
/// devices); content anchored to full bar height with the pill as a
/// background layer.
///
/// Single source of truth: DashboardController.selectedScreen.
/// Perf: zero AnimationControllers — implicit animations only, running
/// solely during the ~320ms morph or a ~110ms press. Nothing at rest.
class CommonBottomNav extends StatefulWidget {
  final Function(int)? onIndexChanged;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;

  /// Fill of the selection pill (top-lit gradient derived from it).
  final Color? pillColor;

  const CommonBottomNav({
    super.key,
    this.onIndexChanged,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.pillColor,
  });

  @override
  State<CommonBottomNav> createState() => _CommonBottomNavState();
}

class _CommonBottomNavState extends State<CommonBottomNav> {
  final DashboardController _dashboardC = Get.find<DashboardController>();

  static const int _kTabCount = 3;

  // ── Config ────────────────────────────────────────────────────────────
  static const double _kBarHeight = 66;
  static const double _kBarRadius = 23;
  static const double _kGlassAlpha = 0.75;
  static const double _kBlurSigma = 18;

  /// Fixed column height: ≤27px icon + 16px label slot.
  static const double _kColumnHeight = 44;

  /// The label lives in a FIXED-height slot with FittedBox(scaleDown).
  /// s8 is .sp-based and double-scales (screen width × system text
  /// scale) — up to ~42px tall on wide foldables at 1.6x, which
  /// overflowed any fixed column budget. The slot makes the column
  /// deterministic: icon(≤27) + 16 = ≤43 at EVERY device/text-scale.
  static const double _kLabelSlotHeight = 16;

  /// OPTICAL CENTERING SHIFT. The bare icon sits at the TOP of the
  /// 44px column (label slot below it), so its visible center is ~8.5px
  /// above the bar's center. When unselected (t=0) the content drops by
  /// this much — putting the icon exactly at bar-center — and rises
  /// back to 0 as the pill blooms and the label appears below it.
  static const double _kUnselectedIconDrop = 8.5;

  /// Icon sizes — the UNSELECTED icon is bigger so bare slots don't feel
  /// visually lighter than the pill.
  static const double _kIconSize = 24;
  static const double _kIconSizeUnselected = 27;

  static const Duration _kMorphMs = Duration(milliseconds: 320);
  static const Duration _kPressMs = Duration(milliseconds: 110);

  /// Press depression depth (px into the glass).
  static const double _kPressDepth = 2.0;

  /// False until the first frame has painted — the initial tab's pill
  /// BLOOMS once on launch instead of starting pre-formed.
  bool _booted = false;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _booted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        // Height on THIS container (the one with the margin) — the
        // float margin is added OUTSIDE the 66px, so the visible bar is
        // truly 66px.
        height: _kBarHeight,
        margin: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kBarRadius),
          boxShadow: const [
            // Contact shadow — tight, dark, right under the glass.
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 12,
              offset: Offset(0, 6),
              spreadRadius: -2,
            ),
            // Ambient shadow — wide and faint. Together they hover the
            // slab above the screen.
            BoxShadow(
              color: Color(0x17000000),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kBarRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _kBlurSigma, sigmaY: _kBlurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _kGlassAlpha),
                borderRadius: BorderRadius.circular(_kBarRadius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── SLAB BEVEL ───────────────────────────────────────
                  // Top strip of glass catches light, bottom strip
                  // darkens — the thickness of the panel. Very low
                  // alphas; material, not decoration.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_kBarRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.50),
                              Colors.white.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.06),
                            ],
                            stops: const [0.0, 0.22, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── CONTENT ──────────────────────────────────────────
                  Positioned.fill(
                    child: Obx(() {
                      final current = _dashboardC.selectedScreen.value.clamp(
                        0,
                        _kTabCount - 1,
                      );
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final slotW = constraints.maxWidth / _kTabCount;
                          return Row(
                            children: [
                              for (var i = 0; i < _kTabCount; i++)
                                Expanded(
                                  child: _buildItem(
                                    icon: const [
                                      Icons.home_rounded,
                                      Icons.event_available_rounded,
                                      Icons.person_rounded,
                                    ][i],
                                    label: const [
                                      'Home',
                                      'Bookings',
                                      'Account',
                                    ][i],
                                    index: i,
                                    selected: i == current,
                                    slotW: slotW,
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
    required bool selected,
    required double slotW,
  }) {
    // Not "selected" until the first frame — the initial pill blooms.
    final active = selected && _booted;
    final pressed = _pressedIndex == index;

    final Color selectedColor =
        widget.selectedIconColor ?? CommonColors.primaryColor;
    final Color unselectedColor = widget.unselectedIconColor ?? Colors.black87;
    final Color pillColor = widget.pillColor ?? CommonColors.blackColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (mounted) setState(() => _pressedIndex = index);
      },
      onTapUp: (_) {
        if (mounted) setState(() => _pressedIndex = null);
      },
      onTapCancel: () {
        if (mounted) setState(() => _pressedIndex = null);
      },
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onIndexChanged?.call(index);
      },
      // BAR-HEIGHT ANCHOR: the content is centered against the FULL bar
      // height, with the pill as a pure background layer below.
      child: SizedBox(
        height: _kBarHeight,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: slotW - 12),
            child: TweenAnimationBuilder<double>(
              // t = the materialization progress. Everything derives
              // from this one value — the bloom is synchronized and
              // reverses cleanly on deselect.
              tween: Tween(begin: 0, end: active ? 1 : 0),
              duration: _kMorphMs,
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                // Pill body: transparent → top-lit black.
                final top = Color.lerp(
                  Colors.transparent,
                  Color.lerp(pillColor, Colors.white, 0.15)!,
                  t,
                )!;
                final bottom = Color.lerp(Colors.transparent, pillColor, t)!;

                // Label trails the bloom slightly.
                final labelT = ((t - 0.18) / 0.82).clamp(0.0, 1.0);
                final iconColor = Color.lerp(
                  unselectedColor,
                  selectedColor,
                  t,
                )!;
                final iconSize =
                    _kIconSizeUnselected +
                    (_kIconSize - _kIconSizeUnselected) * t;

                // ── The pill: a BACKGROUND layer ─────────────────────
                // Zero visual footprint when deselected (fully
                // transparent), blooming up behind the content when
                // selected. It does not participate in the content's
                // layout at all.
                final Widget pillLayer = AnimatedContainer(
                  duration: _kPressMs,
                  curve: Curves.easeOut,
                  // PHYSICAL PRESS: the key travels DOWN into the glass.
                  // A paint-time transform — it can never cause layout
                  // overflow.
                  transform: Matrix4.translationValues(
                    0,
                    pressed ? _kPressDepth : 0,
                    0,
                  ),
                  height: _kColumnHeight + 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [top, bottom],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // EXTRUDED SIDE — hard-edged dark face directly
                      // beneath the pill; compresses on press.
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: (pressed ? 0.24 : 0.40) * t,
                        ),
                        blurRadius: pressed ? 1 : 0,
                        offset: Offset(0, pressed ? 1 : 2.5),
                      ),
                      // Soft ambient shadow under the key.
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16 * t),
                        blurRadius: 8,
                        offset: const Offset(0, 6),
                      ),
                      // EMISSION — warm brand light cast onto the glass.
                      BoxShadow(
                        color: selectedColor.withValues(
                          alpha: (pressed ? 0.10 : 0.16) * t,
                        ),
                        blurRadius: 22,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                );

                // ── The content ───────────────────────────────────────
                // OPTICAL CENTERING: the column reserves a 16px label
                // slot below the icon, so a BARE icon (label invisible)
                // would sit at the top of the column — visibly above the
                // bar's center. The content therefore drops by
                // _kUnselectedIconDrop when bare and rises back to 0 as
                // the pill blooms: the icon is at bar-center in the
                // unselected state, and slides up to make room for the
                // label as it appears. Reads as one deliberate motion.
                final Widget content = Transform.translate(
                  offset: Offset(0, (1 - t) * _kUnselectedIconDrop),
                  child: SizedBox(
                    height: _kColumnHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // No scale-pop: the previous formula
                        // (0.84 + 0.16·curve) held RESTING unselected
                        // icons at 84% scale — they rendered shrunk at
                        // all times, compounding the "small and high"
                        // look. The bloom + color lerp + size lerp are
                        // the whole motion budget now.
                        Icon(icon, size: iconSize, color: iconColor),
                        // Fixed-height label slot — text always laid
                        // out (opacity-driven) inside a 16px box;
                        // FittedBox scales it down when text scale /
                        // device width inflate it.
                        SizedBox(
                          height: _kLabelSlotHeight,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Opacity(
                              opacity: labelT,
                              child: Transform.translate(
                                offset: Offset(0, 4 * (1 - labelT)),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    style: AppType.style(
                                      FontSize.s8,
                                      w: FontWeight.w700,
                                      color: selectedColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                // Content on top; pill behind. The Stack is sized by the
                // CONTENT, so the pill layer can't influence layout.
                return Stack(
                  alignment: Alignment.center,
                  children: [pillLayer, content],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

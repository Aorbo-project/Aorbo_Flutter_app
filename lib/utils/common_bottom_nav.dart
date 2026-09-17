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
///  2. The glass is a THICK SLAB: the top edge catches light and the
///     bottom edge darkens (bevel gradient) — thickness, not a flat rect.
///  3. Dual float shadows (contact + ambient) hover the slab above the
///     screen.
///  4. The selected pill is an EXTRUDED KEY on the glass: top-lit
///     gradient, a hard-edged dark side face beneath it, soft ambient
///     shadow, and a warm brand-colored emission glow.
///  5. Pressing a tab DEPRESSES the key 2px into the glass while its
///     side face compresses — physical press, not a tap.
///
/// Selection is the "bloom" morph: the pill condenses out of the icon's
/// own footprint (one progress value drives pill fade/grow, icon color
/// lerp + pop, label sliding out from behind the icon); deselect
/// reverses. Unselected slots show ONLY a bigger muted icon.
///
/// HEIGHT BUGFIX: the bar's height lives on the margin-bearing Container
/// itself — previously the bottom float margin (2.h ≈ 14px) was deducted
/// FROM the bar height, squeezing the visible bar ~50px against 56px of
/// content (the recurring 2-3px overflow).
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

  /// Fixed column height: 27px icon + gap + s8 label line.
  static const double _kColumnHeight = 44;

  /// The label lives in a FIXED-height slot with FittedBox(scaleDown).
  /// s8 is .sp-based and double-scales (screen width × system text
  /// scale) — up to ~42px tall on wide foldables at 1.6x, which
  /// overflowed any fixed column budget. The slot makes the column
  /// deterministic: icon(≤27) + 16 = ≤43 at EVERY device/text-scale.
  static const double _kLabelSlotHeight = 16;

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
        // THE FIX: height on THIS container (the one with the margin) —
        // the float margin is added OUTSIDE the 66px, so the visible bar
        // is truly 66px. (Before, SizedBox(66) wrapped the margin, so
        // 2.h came OFF the bar — the recurring overflow.)
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
                  // Under the content: the top strip of glass catches
                  // light, the bottom strip darkens — the thickness of
                  // the panel. Very low alphas; it reads as material,
                  // not decoration.
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
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: slotW - 12),
          child: TweenAnimationBuilder<double>(
            // t = the materialization progress. Everything derives from
            // this one value — the bloom is synchronized and reverses
            // cleanly on deselect.
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
              final iconColor = Color.lerp(unselectedColor, selectedColor, t)!;
              final iconSize =
                  _kIconSizeUnselected +
                  (_kIconSize - _kIconSizeUnselected) * t;

              return AnimatedContainer(
                duration: _kPressMs,
                curve: Curves.easeOut,
                // PHYSICAL PRESS: the key travels DOWN into the glass.
                // A paint-time transform — it can never cause layout
                // overflow, and the bar's slack absorbs the 2px.
                transform: Matrix4.translationValues(
                  0,
                  pressed ? _kPressDepth : 0,
                  0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [top, bottom],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // EXTRUDED SIDE — hard-edged dark face directly
                    // beneath the pill. On press it compresses (thinner
                    // + sharper), like the key sinking into the slab.
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
                child: SizedBox(
                  height: _kColumnHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: (0.84 + 0.16 * Curves.easeOutBack.transform(t))
                            .clamp(0.1, 1.3),
                        child: Icon(icon, size: iconSize, color: iconColor),
                      ),
                      // Fixed-height label slot — the text is always
                      // laid out (opacity-driven) inside a 16px box and
                      // scales itself down under FittedBox when text
                      // scale / device width inflate it. No config can
                      // exceed the column budget.
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
            },
          ),
        ),
      ),
    );
  }
}

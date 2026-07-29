// lib/theme/app_tokens.dart
//
// SINGLE SOURCE OF TRUTH for color, spacing, radius, shadow, gradient and
// motion. Changing a value here propagates app-wide.
//
// Migration rule: existing file-private token classes (_TI, _C, _TC, _BC,
// _NT, _FT, ...) keep their names, but their members become one-line
// aliases into these tokens. New code imports this file directly.

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────
//  COLOR
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Brand — forest green identity (trek card redesign)
  static const forestDeep = Color(0xFF1B4332);
  static const forest = Color(0xFF2D6A4F);
  static const forestSoft = Color(0xFFE8F3ED);

  // Secondary — teal (refunds, confirmations)
  static const teal = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFF1AA090);
  static const tealSoft = Color(0xFFE6F5F3);

  // Accent
  static const amber = Color(0xFFD97706);
  static const amberSoft = Color(0xFFFFF8EB);
  static const gold = Color(0xFFFFB800);
  static const brandYellow = Color(0xFFFFF200);

  // Ink scale
  static const ink = Color(0xFF111827);
  static const inkStrong = Color(0xFF0F172A);
  static const inkMid = Color(0xFF6B7280);
  static const inkLight = Color(0xFF9CA3AF);

  // Surfaces
  static const surface = Colors.white;
  static const bg = Color(0xFFFAFAFA); // app-wide standard background
  static const bgCool = Color(0xFFF5F8FF); // legacy cool screens (phase out)
  static const elevated = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFE2E8F0);
  static const iconBadge = Color(0xFF111827);

  // Status
  static const success = Color(0xFF059669);
  static const successSoft = Color(0xFFF0FDF4);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFFE4E4);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFEF3C7);
  static const info = Color(0xFF2563EB);
  static const infoSoft = Color(0xFFDBEAFE);
}

// ─────────────────────────────────────────────
//  GRADIENTS
// ─────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  /// The one CTA gradient (Continue / Pay Now / Save / Done).
  static const cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.forestDeep, AppColors.forest],
  );

  static const dangerHold = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF991B1B), AppColors.danger],
  );

  static const tealAccent = LinearGradient(
    colors: [AppColors.teal, AppColors.tealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────
//  SPACING (sizer-backed; use these instead of raw .w/.h literals)
// ─────────────────────────────────────────────
class AppSpace {
  AppSpace._();

  // Vertical rhythm
  static double get vXs => 0.5.h;
  static double get vSm => 1.h;
  static double get vMd => 1.5.h;
  static double get vLg => 2.h;
  static double get vXl => 3.h;

  // Horizontal rhythm
  static double get hXs => 1.w;
  static double get hSm => 2.w;
  static double get hMd => 3.w;
  static double get hLg => 4.w;
  static double get hXl => 5.w;

  /// Standard screen gutter (the app already converged on 4.w).
  static double get gutter => 4.w;
}

// ─────────────────────────────────────────────
//  RADIUS
// ─────────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static double get sm => 2.w; // inputs, inner chips
  static double get md => 3.w; // buttons, tiles
  static double get lg => 4.w; // cards
  static double get xl => 5.w; // sheets
  static const double pill = 999;
}

// ─────────────────────────────────────────────
//  SHADOWS
// ─────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card() => [
    BoxShadow(
      color: AppColors.forestDeep.withValues(alpha: 0.10),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.forestDeep.withValues(alpha: 0.05),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> soft([double opacity = 0.06]) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: opacity),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> cta(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.30),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];
}

// ─────────────────────────────────────────────
//  MOTION
// ─────────────────────────────────────────────
class AppMotion {
  AppMotion._();

  static const fast = Duration(milliseconds: 150); // presses, chips
  static const medium = Duration(milliseconds: 280); // expand/collapse
  static const slow = Duration(milliseconds: 480); // sheets, panels
  static const entrance = Duration(milliseconds: 600); // staggered entrances
  static const stagger = Duration(milliseconds: 90); // per-item delay

  static const easeOut = Curves.easeOutCubic;
  static const easeIn = Curves.easeInCubic;
  static const spring = Curves.easeOutBack;
  static const emphasized = Curves.elasticOut;
}

import "package:flutter/material.dart";

/// Slate + teal design tokens used by the search-summary / filter-bar
/// screens. Kept as its own token set (not merged into [CommonColors])
/// because it's a distinct, internally-consistent visual language from
/// the yellow-brand palette used across the rest of the app — merging
/// would mean rewriting 150+ call sites in search_summary_screen.dart
/// and common_filter_bar.dart for no visual benefit today.
class AroboTheme {
  // ── Brand ─────────────────────────────────────────────
  static const primary = Color(0xFF0F172A); // Deep Slate for Professional Look
  static const primaryLight = Color(0xFF334155);
  static const teal = Color(0xFF0F7B6C);
  static const tealLight = Color(0xFF1AA090);
  static const tealDeep = Color(0xFF0A5C50);
  static const tealSoft = Color(0xFFE6F5F3);
  static const tealGlow = Color(0x330F7B6C);
  // ── Surfaces ──────────────────────────────────────────
  static const bg = Color(0xFFF8FAFC); // Clean Light Slate Background
  static const cardBg = Color(0xFFFFFFFF);
  static const elevated = Color(0xFFF1F5F9);
  static const surfaceCard = Color(0xFFE8F0EE);
  // ── Ink ───────────────────────────────────────────────
  static const ink = Color(0xFF0F172A);
  static const ink200 = Color(0xFF334155);
  static const ink400 = Color(0xFF64748B);
  static const inkMid = Color(0xFF94A3B8);
  static const inkLight = Color(0xFFCBD5E1);
  static const ink600 = Color(0xFFE2E8F0);
  // ── Lines & status ────────────────────────────────────
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFF1F5F9);
  static const danger = Color(0xFFEF4444);
  static const star = Color(0xFFF59E0B);
  static const price = Color(0xFF0F172A); // Dark Slate for Prices
  static const iconBadge = Color(0xFF0F172A);
  // ── Gradients ─────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const tealGradient = LinearGradient(
    colors: [teal, tealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const deepTealGradient = LinearGradient(
    colors: [teal, tealDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x66000000)],
  );
  // ── Shadows ───────────────────────────────────────────
  static List<BoxShadow> softShadow([double opacity = 0.04]) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> cardShadow() => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      offset: const Offset(0, 2),
      blurRadius: 10,
    ),
  ];
  static List<BoxShadow> accentGlow(double opacity) => [
    BoxShadow(
      color: teal.withValues(alpha: opacity),
      blurRadius: 16,
      spreadRadius: -2,
      offset: const Offset(0, 4),
    ),
  ];
  // ── Motion ────────────────────────────────────────────
  static const durFast = Duration(milliseconds: 180);
  static const durMed = Duration(milliseconds: 280);
  static const durSlow = Duration(milliseconds: 480);
  static const easeOut = Curves.easeOutCubic;
  static const spring = Curves.easeOutBack;
  static const embounce = Curves.easeOutBack;
  // ── Typography ────────────────────────────────────────
  static TextStyle label({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = ink,
    double letterSpacing = 0,
    double height = 1.3,
  }) => TextStyle(
    fontFamily: 'Poppins',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
  static const radiusCard = 16.0;
  static const radiusLg = 20.0;
  static const radiusXl = 24.0;
  static const radiusPill = 999.0;
}

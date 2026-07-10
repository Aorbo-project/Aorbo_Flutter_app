// ─────────────────────────────────────────────────────────────────────────────
// THEME FILE INTEGRATION (Place this in your app_theme.dart)
// ─────────────────────────────────────────────────────────────────────────────
import "package:arobo_app/utils/common_colors.dart";
import "package:flutter/material.dart";

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

class AroboPersonalization {
  AroboPersonalization._();
  static final AroboPersonalization instance = AroboPersonalization._();
  final Set<String> _favorites = {};
  final List<String> _recentlyViewed = [];
  String _userName = '';
  Set<String> get favorites => _favorites;
  List<String> get recentlyViewed => _recentlyViewed;
  bool isFavorite(String? id) => id != null && _favorites.contains(id);
  void toggleFavorite(String? id) {
    if (id == null) return;
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
  }

  void pushRecent(String? id) {
    if (id == null) return;
    _recentlyViewed.remove(id);
    _recentlyViewed.insert(0, id);
    if (_recentlyViewed.length > 10) _recentlyViewed.removeLast();
  }

  String get greeting {
    final h = DateTime.now().hour;
    final prefix = h < 12
        ? 'Good morning'
        : (h < 17 ? 'Good afternoon' : 'Good evening');
    return _userName.isEmpty ? prefix : '$prefix, $_userName';
  }

  void setUserName(String n) => _userName = n;

  double scoreFor(id, rating, price, hasDiscount) {
    var s = 0.0;
    s += (rating ?? 0) * 2.0;
    if (hasDiscount == true) s += 1.2;
    if (isFavorite(id?.toString())) s += 0.6;
    return s;
  }
}

class AppTheme {
  static const MaterialColor primaryBlue =
      MaterialColor(_bluePrimaryValue, <int, Color>{
        50: Color(0xff001B38),
        100: Color(0xff001B38),
        200: Color(0xff001B38),
        300: Color(0xff001B38),
        400: Color(0xff001B38),
        500: Color(_bluePrimaryValue),
        600: Color(0xff001B38),
        700: Color(0xff001B38),
        800: Color(0xff001B38),
        900: Color(0xff001B38),
      });

  static LinearGradient customGradient(List<String>? colors) {
    final colorList = (colors == null || colors.isEmpty)
        ? [CommonColors.whiteColor, CommonColors.primaryColor]
        : colors.map((col) => hexToColor(col)).toList();
    final stops = List.generate(
      colorList.length,
      (index) => index / (colorList.length - 1),
    );
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colorList,
      stops: stops,
    );
  }

  static Color hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFFFFFFF);
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFFFFFFFF);
    }
  }

  static const int _bluePrimaryValue = 0xff001B38;

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: CommonColors.whiteColor,
    fontFamily: "Poppins",
    primarySwatch: primaryBlue,
    primaryColor: const Color(0xffFFFFFF),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    primarySwatch: primaryBlue,
    brightness: Brightness.dark,
  );

  static const int _darkPrimary = 0xff474747;
  static const MaterialColor primaryDark =
      MaterialColor(_darkPrimary, <int, Color>{
        50: Color(0xff474747),
        100: Color(0xff474747),
        200: Color(0xff474747),
        300: Color(0xff474747),
        400: Color(0xff474747),
        500: Color(_darkPrimary),
        600: Color(0xff474747),
        700: Color(0xff474747),
        800: Color(0xff474747),
        900: Color(0xff474747),
      });
}

import "package:arobo_app/utils/common_colors.dart";
import "package:arobo_app/utils/app_text_styles.dart";
import "package:flutter/material.dart";

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

  // Real ColorScheme sourced from the app's actual brand tokens (was
  // previously a `primarySwatch` navy swatch immediately overridden by an
  // explicit white `primaryColor`, so it had no real effect — any default,
  // unstyled Material widget (Switch, Checkbox, text-selection handles,
  // ripple color) was silently falling back to Flutter's stock purple
  // instead of the app's yellow/teal brand). `textTheme` only affects
  // Text widgets that don't already set an explicit style, so screens
  // using AppTextStyles/inline TextStyle are unaffected.
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: CommonColors.whiteColor,
    fontFamily: "Poppins",
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: const ColorScheme.light(
      primary: CommonColors.primaryColor,
      onPrimary: CommonColors.searchbtntext,
      secondary: CommonColors.appColor,
      onSecondary: CommonColors.whiteColor,
      surface: CommonColors.whiteColor,
      onSurface: CommonColors.textColor,
      error: CommonColors.materialRed,
      onError: CommonColors.whiteColor,
    ),
    textTheme: TextTheme(
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonText,
    ),
  );
}

import "package:arobo_app/utils/common_colors.dart";
import "package:flutter/material.dart";

class AppTheme {
  ///convert app orange color in MaterialColor for app theme
  static const MaterialColor primaryBlue = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
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
    },
  );


  static LinearGradient customGradient(List<String>? colors) {
    final colorList = (colors == null || colors.isEmpty)
        ? [
      CommonColors.whiteColor,
      CommonColors.primaryColor,
    ]
        : colors.map((col) => hexToColor(col)).toList();

    // Generate matching stops dynamically
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
    // Default to white if null or empty
    if (hex == null || hex.isEmpty) {
      return const Color(0xFFFFFFFF);
    }

    hex = hex.replaceAll('#', '');

    // Add opacity if missing
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      // Fallback to white if parsing fails
      return const Color(0xFFFFFFFF);
    }
  }

  ///orange primary color
  static const int _bluePrimaryValue = 0xff001B38;

  ///define light theme
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: CommonColors.whiteColor,
    fontFamily: "Poppins",
    primarySwatch: primaryBlue,
    primaryColor: const Color(0xffFFFFFF),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static ThemeData darkTheme = ThemeData(
    // fontFamily: "Montserrat",
    primaryColor: Colors.black,
    primarySwatch: primaryBlue,
    brightness: Brightness.dark,
  );

  static const int _darkPrimary = 0xff474747;
  static const MaterialColor primaryDark = MaterialColor(
    _darkPrimary,
    <int, Color>{
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
    },
  );
}

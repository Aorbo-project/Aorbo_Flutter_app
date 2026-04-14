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


  static Color hexToColor(String hex) {
    if(hex.isEmpty) return Color(0xffffffff);
    hex = hex.replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex'; // add full opacity if not provided
    }

    return Color(int.parse(hex, radix: 16));
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

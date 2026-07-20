import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F6F6),
    primaryColor: const Color(0xFFF03B3B),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFF03B3B),
      secondary: Color(0xFFF03B3B),
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0.5,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFF1F1F1),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: const Color(0xFFF03B3B),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFF03B3B),
      secondary: Color(0xFFF03B3B),
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0.5,
      backgroundColor: Color(0xFF1E1E1E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: const Color(0xFF2D2D2D),
  );
}

import 'package:flutter/material.dart';

class AppTheme {
  static final pinkColor = Color(0xFFE91E63);
  static final lightPinkColor = Color(0xFFFCE4EC);

  static final themeData = ThemeData(
    primaryColor: pinkColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: pinkColor,
      primary: pinkColor,
      secondary: Colors.pinkAccent,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: pinkColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: pinkColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: pinkColor, width: 2),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF003B56);
  static const Color secondary = Color(0xFF0A6D9A);
  static const Color tertiary = Color(0xFF28A5DE);
  static const Color quaternary = Color(0xFF6ACDFF);
  static const Color accent = Color(0xFFABEBFF);
  static const Color background = Color(0xFFEAF8FF);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  ThemeData getTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: white,
        secondary: secondary,
        onSecondary: white,
        error: Colors.red,
        onError: white,
        surface: white,
        onSurface: black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppTheme.white,
        selectedColor: AppTheme.tertiary,
        secondarySelectedColor: AppTheme.quaternary,
        disabledColor: Colors.grey,
        labelStyle: TextStyle(color: AppTheme.black, fontSize: 14),
        secondaryLabelStyle: TextStyle(color: AppTheme.white, fontSize: 14),
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(color: black, fontSize: 16),
        labelMedium: TextStyle(
          color: tertiary,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: tertiary),
        ),
        labelStyle: const TextStyle(color: secondary),
        filled: true,
        fillColor: white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primary,
        selectedItemColor: tertiary,
        unselectedItemColor: white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

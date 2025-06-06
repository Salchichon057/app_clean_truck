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
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
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
    );
  }
}

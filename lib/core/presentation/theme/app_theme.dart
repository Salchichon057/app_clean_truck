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
        background: background,
        onBackground: black,
        surface: white,
        onSurface: black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: white),
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
        labelStyle: TextStyle(color: AppTheme.primary, fontSize: 14),
        secondaryLabelStyle: TextStyle(color: AppTheme.white, fontSize: 14),
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide.none,
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: white,
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
        hintStyle: const TextStyle(color: black),
        filled: true,
        fillColor: white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: primary),
        displayMedium: TextStyle(color: primary),
        displaySmall: TextStyle(color: primary),
        headlineLarge: TextStyle(
          color: primary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(color: primary),
        headlineSmall: TextStyle(color: primary),
        titleLarge: TextStyle(color: primary),
        titleMedium: TextStyle(color: primary),
        titleSmall: TextStyle(color: primary),
        bodyLarge: TextStyle(color: black, fontSize: 18),
        bodyMedium: TextStyle(color: black, fontSize: 16),
        bodySmall: TextStyle(color: black, fontSize: 14),
        labelLarge: TextStyle(color: secondary, fontSize: 16),
        labelMedium: TextStyle(
          color: tertiary,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
        labelSmall: TextStyle(color: secondary, fontSize: 12),
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
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: secondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: tertiary, width: 2),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: TextStyle(color: white),
        actionTextColor: accent,
      ),
    );
  }
}
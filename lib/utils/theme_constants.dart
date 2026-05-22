import 'package:flutter/material.dart';

class ThemeConstants {
  // Brand colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF0EA5E9); // Sky blue
  static const Color accentColor = Color(0xFF10B981); // Emerald Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber Yellow
  static const Color dangerColor = Color(0xFFEF4444); // Rose Red

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color darkCardBg = Color(0xFF1E293B); // Slate 800
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkBorder = Color(0xFF334155); // Slate 700

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightCardBg,
      error: dangerColor,
    ),
    scaffoldBackgroundColor: lightBg,
    cardTheme: CardThemeData(
      color: lightCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextPrimary),
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: lightTextPrimary),
      bodyMedium: TextStyle(color: lightTextSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerColor),
      ),
      labelStyle: const TextStyle(color: lightTextSecondary),
      hintStyle: const TextStyle(color: lightTextSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCardBg,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextSecondary,
      elevation: 8,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkCardBg,
      error: dangerColor,
    ),
    scaffoldBackgroundColor: darkBg,
    cardTheme: CardThemeData(
      color: darkCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerColor),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
      hintStyle: const TextStyle(color: darkTextSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardBg,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextSecondary,
      elevation: 8,
    ),
  );
}

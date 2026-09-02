import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primarySeed = Color.fromARGB(255, 180, 19, 19);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
}

class AppTheme {
  AppTheme._();

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarySeed,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primarySeed,
      onPrimary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: const Color(0xFF1A1A1A),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: _appBarTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      cardTheme: CardThemeData(color: AppColors.lightSurface, elevation: 1),
    );
  }

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarySeed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primarySeed,
      onPrimary: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: _appBarTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      cardTheme: const CardThemeData(color: AppColors.darkSurface, elevation: 1),
    );
  }

  // ==================== SHARED COMPONENT STYLES ====================
  static AppBarTheme _appBarTheme(ColorScheme colors) {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
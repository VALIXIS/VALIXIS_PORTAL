import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Glassmorphic Obsidian Dark Theme ThemeData for VALIXIS Flow
class ValixisTheme {
  ValixisTheme._();

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.obsidianDark,
      primaryColor: AppColors.electricCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricCyan,
        secondary: AppColors.emeraldGreen,
        surface: AppColors.obsidianSurface,
        error: AppColors.coralRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidianSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

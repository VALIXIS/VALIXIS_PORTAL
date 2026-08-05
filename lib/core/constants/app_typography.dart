import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// VALIXIS typography scale — Inter font family.
abstract final class AppTypography {
  static TextTheme get textTheme => TextTheme(
        // Display
        displayLarge: _inter(
          size: 57,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.12,
          spacing: -0.25,
        ),
        displayMedium: _inter(
          size: 45,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.16,
        ),
        displaySmall: _inter(
          size: 36,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.22,
        ),

        // Headline
        headlineLarge: _inter(
          size: 32,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.25,
        ),
        headlineMedium: _inter(
          size: 28,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.29,
        ),
        headlineSmall: _inter(
          size: 24,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.33,
        ),

        // Title
        titleLarge: _inter(
          size: 22,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.27,
        ),
        titleMedium: _inter(
          size: 16,
          weight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.5,
          spacing: 0.15,
        ),
        titleSmall: _inter(
          size: 14,
          weight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.43,
          spacing: 0.1,
        ),

        // Body
        bodyLarge: _inter(
          size: 16,
          weight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
          spacing: 0.5,
        ),
        bodyMedium: _inter(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.43,
          spacing: 0.25,
        ),
        bodySmall: _inter(
          size: 12,
          weight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.33,
          spacing: 0.4,
        ),

        // Label
        labelLarge: _inter(
          size: 14,
          weight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.43,
          spacing: 0.1,
        ),
        labelMedium: _inter(
          size: 12,
          weight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.33,
          spacing: 0.5,
        ),
        labelSmall: _inter(
          size: 11,
          weight: FontWeight.w500,
          color: AppColors.textMuted,
          height: 1.45,
          spacing: 0.5,
        ),
      );

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.0,
    double spacing = 0.0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: spacing,
      );
}

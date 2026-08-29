import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// VALIXIS typography scale — Plus Jakarta Sans font family.
abstract final class AppTypography {
  static TextTheme get textTheme => TextTheme(
        // Display
        displayLarge: _font(
          size: 57,
          weight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.12,
          spacing: -0.5,
        ),
        displayMedium: _font(
          size: 45,
          weight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.16,
          spacing: -0.4,
        ),
        displaySmall: _font(
          size: 36,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.22,
          spacing: -0.3,
        ),

        // Headline
        headlineLarge: _font(
          size: 32,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.25,
          spacing: -0.3,
        ),
        headlineMedium: _font(
          size: 28,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.29,
          spacing: -0.25,
        ),
        headlineSmall: _font(
          size: 24,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.33,
          spacing: -0.2,
        ),

        // Title
        titleLarge: _font(
          size: 22,
          weight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.27,
          spacing: -0.15,
        ),
        titleMedium: _font(
          size: 16,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.45,
          spacing: 0.0,
        ),
        titleSmall: _font(
          size: 14,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.43,
          spacing: 0.0,
        ),

        // Body
        bodyLarge: _font(
          size: 16,
          weight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
          spacing: 0.1,
        ),
        bodyMedium: _font(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.43,
          spacing: 0.1,
        ),
        bodySmall: _font(
          size: 12,
          weight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.35,
          spacing: 0.1,
        ),

        // Label
        labelLarge: _font(
          size: 14,
          weight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.43,
          spacing: 0.1,
        ),
        labelMedium: _font(
          size: 12,
          weight: FontWeight.w600,
          color: AppColors.textSecondary,
          height: 1.33,
          spacing: 0.2,
        ),
        labelSmall: _font(
          size: 11,
          weight: FontWeight.w600,
          color: AppColors.textMuted,
          height: 1.45,
          spacing: 0.3,
        ),
      );

  static TextStyle _font({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.0,
    double spacing = 0.0,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: spacing,
      );
}

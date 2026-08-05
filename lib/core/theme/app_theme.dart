import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_border_radius.dart';
import '../constants/app_typography.dart';

/// VALIXIS Material 3 dark theme.
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _colorScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.surfaceBase,
        cardColor: AppColors.surfaceCard,
        dividerColor: AppColors.divider,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),

        // InputDecoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide:
                const BorderSide(color: AppColors.brandBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandCyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 0,
        ),

        // NavigationRail
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: AppColors.surfaceCard,
          indicatorColor: Color(0x333D5AFE),
          selectedIconTheme: IconThemeData(color: AppColors.brandBlue),
          unselectedIconTheme: IconThemeData(color: AppColors.textMuted),
          selectedLabelTextStyle: TextStyle(
            color: AppColors.brandBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
          elevation: 0,
          useIndicator: true,
        ),

        // Tooltip
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          textStyle:
              const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      );

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.brandBlue,
    onPrimary: AppColors.onPrimary,
    primaryContainer: Color(0xFF1A237E),
    onPrimaryContainer: AppColors.brandCyan,
    secondary: AppColors.brandPurple,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: Color(0xFF2D1B69),
    onSecondaryContainer: Color(0xFFD0BCFF),
    tertiary: AppColors.brandCyan,
    onTertiary: AppColors.surfaceBase,
    tertiaryContainer: Color(0xFF00363D),
    onTertiaryContainer: AppColors.brandCyan,
    error: AppColors.error,
    onError: AppColors.surfaceBase,
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.surfaceCard,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.surfaceBase,
    inversePrimary: AppColors.brandBlue,
  );
}

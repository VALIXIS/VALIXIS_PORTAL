import 'package:flutter/material.dart';

/// Centralized color tokens for VALIXIS BUSINESS OS.
/// Follows a futuristic, premium, dark, glassmorphic visual identity
/// with cyan and purple accents and enterprise ergonomics.
class AppColors {
  AppColors._();

  // Background tokens
  static const Color background = Color(0xFF070B14);
  static const Color backgroundElevated = Color(0xFF0E1424);

  // Surface tokens
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceElevated = Color(0xFF1A243B);

  // Glass tokens
  static final Color glass = const Color(0xFF131D33).withValues(alpha: 0.60);
  static final Color glassStrong = const Color(
    0xFF1A2644,
  ).withValues(alpha: 0.85);

  // Border tokens
  static final Color border = Colors.white.withValues(alpha: 0.08);
  static final Color borderStrong = Colors.white.withValues(alpha: 0.16);

  // Brand primary & variant (Cyan core)
  static const Color primary = Color(0xFF06B6D4);
  static const Color primaryVariant = Color(0xFF0891B2);

  // Secondary & Accent (Purple / Electric Blue)
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF38BDF8);

  // Semantic status feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Typography tokens
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Overlay token
  static final Color overlay = Colors.black.withValues(alpha: 0.65);

  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF141E34), Color(0xFF0D1424)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final Color glassBorderActive = const Color(
    0xFF06B6D4,
  ).withValues(alpha: 0.4);

  // Backward-compatibility aliases
  static const Color primaryCyan = primary;
  static const Color primaryPurple = secondary;
  static const Color brandBlue = info;
  static const Color brandIndigo = secondary;
  static const Color surfaceDark = backgroundElevated;
  static const Color surfaceCard = surface;
  static Color get glassBg => glass;
  static Color get glassBorder => border;
  static const Color primaryBlue = info;
  static const Color accentTeal = primary;
  static const Color statusGreen = success;
  static const Color statusOrange = warning;
  static const Color statusRed = error;
  static const Color statusPurple = secondary;
  static const Color cardDark = surface;
  static const Color cardDarkElevated = surfaceElevated;
  static Color get borderSubtle => border;
}

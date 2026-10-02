import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PulseColors {
  // Obsidian Canvas
  static const Color backgroundObsidian = Color(0xFF07090E);
  static const Color surfaceObsidian = Color(0xFF0D111A);
  static const Color cardObsidian = Color(0xFF131825);
  static const Color cardGlassBorder = Color(0xFF20293D);

  // Status Health Ambient Gradients
  static const Color electricCyan = Color(0xFF00F2FE);
  static const Color cyanGlow = Color(0xFF4FACFE);

  static const Color emeraldGrowth = Color(0xFF10B981);
  static const Color emeraldGlow = Color(0xFF34D399);

  static const Color coralRedAlert = Color(0xFFEF4444);
  static const Color coralGlow = Color(0xFFF87171);

  // Text & Accent Colors
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color accentPurple = Color(0xFF8B5CF6);
}

class PulseTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: PulseColors.backgroundObsidian,
      colorScheme: const ColorScheme.dark(
        primary: PulseColors.electricCyan,
        secondary: PulseColors.emeraldGrowth,
        surface: PulseColors.surfaceObsidian,
        error: PulseColors.coralRedAlert,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: PulseColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: PulseColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PulseColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: PulseColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: PulseColors.textSecondary,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: PulseColors.textMuted,
        ),
      ),
    );
  }
}

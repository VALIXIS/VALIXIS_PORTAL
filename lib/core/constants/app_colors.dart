import 'package:flutter/material.dart';

/// VALIXIS brand color palette.
/// All colors extracted from official brand assets.
/// Never hardcode color values outside this file.
abstract final class AppColors {
  // ── Brand gradient stops ──────────────────────────────────────────────────
  static const Color brandCyan = Color(0xFF00E5FF);
  static const Color brandBlue = Color(0xFF3D5AFE);
  static const Color brandPurple = Color(0xFF7C3AED);

  // ── Primary / Interactive ─────────────────────────────────────────────────
  static const Color primary = brandBlue;
  static const Color primaryVariant = Color(0xFF5C77FF);
  static const Color secondary = brandPurple;
  static const Color accent = brandCyan;

  // ── Surfaces (Deep Obsidian Hierarchy) ────────────────────────────────────
  static const Color surfaceBase = Color(0xFF060914);
  static const Color surfaceBaseDeep = Color(0xFF03060D);
  static const Color surfaceCard = Color(0xFF0B1122);
  static const Color surfaceCardHover = Color(0xFF101932);
  static const Color surfaceElevated = Color(0xFF131D36);
  static const Color surfaceGlass = Color(0xFF182344);
  static const Color surfaceGlassHover = Color(0xFF1F2E58);

  // ── Glass & Luminescence Overlays ─────────────────────────────────────────
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassWhiteHover = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderSubtle = Color(0x0FFFFFFF);
  static const Color glassBorderGlow = Color(0x3300E5FF);
  static const Color glassBorderPrimary = Color(0x403D5AFE);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF334155);

  // ── Semantic & Telemetry Status ───────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = brandCyan;

  static const Color telemetryCyan = Color(0xFF00E5FF);
  static const Color telemetryBlue = Color(0xFF3D5AFE);
  static const Color telemetryIndigo = Color(0xFF6366F1);
  static const Color telemetryViolet = Color(0xFF8B5CF6);
  static const Color telemetryAmber = Color(0xFFF59E0B);
  static const Color telemetryEmerald = Color(0xFF10B981);
  static const Color telemetryRose = Color(0xFFF43F5E);

  // ── Dividers & borders ────────────────────────────────────────────────────
  static const Color divider = Color(0xFF1A233A);
  static const Color border = Color(0xFF1E293B);
  static const Color borderHover = Color(0xFF334155);

  // ── Brand gradients ───────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandCyan, brandBlue, brandPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandBlue, brandPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGlowGradient = LinearGradient(
    colors: [Color(0x3300E5FF), Color(0x0500E5FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient activeTabGradient = LinearGradient(
    colors: [Color(0x2E3D5AFE), Color(0x0A3D5AFE)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF050813), Color(0xFF080D20), Color(0xFF050813)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

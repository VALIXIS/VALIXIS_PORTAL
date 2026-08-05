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

  // ── Surfaces ──────────────────────────────────────────────────────────────
  static const Color surfaceBase = Color(0xFF060914);
  static const Color surfaceCard = Color(0xFF0E1425);
  static const Color surfaceElevated = Color(0xFF141B30);
  static const Color surfaceGlass = Color(0xFF1A2440);

  // ── Glass overlay ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF90A4AE);
  static const Color textMuted = Color(0xFF546E7A);
  static const Color textDisabled = Color(0xFF37474F);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD740);
  static const Color error = Color(0xFFFF5252);
  static const Color info = brandCyan;

  // ── Dividers & borders ────────────────────────────────────────────────────
  static const Color divider = Color(0xFF1E2A3A);
  static const Color border = Color(0xFF243044);

  // ── Brand gradient ────────────────────────────────────────────────────────
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

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF060914), Color(0xFF0A1128), Color(0xFF060914)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

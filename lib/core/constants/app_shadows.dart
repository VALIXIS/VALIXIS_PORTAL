import 'package:flutter/material.dart';
import 'app_colors.dart';

/// VALIXIS shadow tokens.
/// Multi-tiered depth hierarchy and subtle obsidian glows.
abstract final class AppShadows {
  /// Subtle card elevation for deep obsidian surfaces.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A00E5FF),
      blurRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  /// Interactive hover elevation with crisp luminescence.
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x3300E5FF),
      blurRadius: 12,
      spreadRadius: -2,
      offset: Offset(0, 0),
    ),
  ];

  /// Modal / dialog elevated surface.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0xCC000000),
      blurRadius: 48,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x223D5AFE),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Primary brand glow (blue).
  static const List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: Color(0x403D5AFE),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];

  /// Cyan accent glow.
  static const List<BoxShadow> glowAccent = [
    BoxShadow(
      color: Color(0x3300E5FF),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Live status active pip glow.
  static List<BoxShadow> pipGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.6),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];

  /// Glass panel border glow.
  static List<BoxShadow> glass = [
    BoxShadow(
      color: AppColors.glassWhite,
      blurRadius: 0,
      offset: const Offset(0, 0),
    ),
  ];
}

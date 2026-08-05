import 'package:flutter/material.dart';
import 'app_colors.dart';

/// VALIXIS shadow tokens.
/// Uses brand-colored glows for an on-brand premium feel.
abstract final class AppShadows {
  /// Subtle card elevation.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Modal / dialog elevation.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  /// Primary brand glow (blue).
  static const List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: Color(0x663D5AFE),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Cyan accent glow.
  static const List<BoxShadow> glowAccent = [
    BoxShadow(
      color: Color(0x4D00E5FF),
      blurRadius: 32,
      spreadRadius: -4,
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

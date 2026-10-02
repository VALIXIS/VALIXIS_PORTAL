import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicTokens {
  static const double blurSigmaX = 16.0;
  static const double blurSigmaY = 16.0;
  static const double borderRadius = 16.0;

  static ImageFilter get glassFilter => ImageFilter.blur(
        sigmaX: blurSigmaX,
        sigmaY: blurSigmaY,
      );

  static BoxDecoration glassBoxDecoration({
    Color backgroundColor = const Color(0xFF0D111A),
    Color borderColor = const Color(0xFF20293D),
    double opacity = 0.85,
  }) {
    return BoxDecoration(
      color: backgroundColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.0),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_shadows.dart';

/// A glassmorphism-style card widget.
///
/// Applies a blur backdrop, translucent fill, and a subtle border.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.blurSigma = 16.0,
    this.showGlow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double blurSigma;

  /// When true, adds a subtle brand-blue glow shadow.
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.xl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: showGlow ? AppShadows.glowPrimary : AppShadows.card,
          ),
          child: child,
        ),
      ),
    );
  }
}

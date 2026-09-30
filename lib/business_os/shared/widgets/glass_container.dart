import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Centralized glassmorphic container for VALIXIS BUSINESS OS.
/// Optimized for Flutter Web performance with controlled blur and translucent layers.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? customColor;
  final Border? customBorder;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final double blurSigma;
  final bool enableBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.customColor,
    this.customBorder,
    this.gradient,
    this.shadows,
    this.blurSigma = 12.0,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(14);
    final effectiveBorder = customBorder ?? Border.all(color: AppColors.border);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: customColor ?? AppColors.glass,
        gradient: gradient,
      ),
      child: child,
    );

    if (enableBlur && blurSigma > 0) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(borderRadius: effectiveRadius, child: content);
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: content,
    );
  }
}

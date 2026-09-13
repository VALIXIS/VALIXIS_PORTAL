import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_durations.dart';

/// A premium glassmorphism-style card widget for the VALIXIS command center.
///
/// Features backdrop blur, deep obsidian translucency, subtle border highlights,
/// and optional hover micro-elevation.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.blurSigma = 16.0,
    this.showGlow = false,
    this.borderColor,
    this.backgroundColor,
    this.isInteractive = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double blurSigma;

  /// When true, adds a subtle brand glow shadow.
  final bool showGlow;

  /// Custom border color override.
  final Color? borderColor;

  /// Custom background color override.
  final Color? backgroundColor;

  /// When true, enables subtle hover micro-lift and border illumination.
  final bool isInteractive;

  /// Optional click/tap handler.
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppRadius.xl;
    final isHoverEnabled = widget.isInteractive || widget.onTap != null;

    final cardChild = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurSigma,
          sigmaY: widget.blurSigma,
        ),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.snappy,
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (_isHovered ? AppColors.glassWhiteHover : AppColors.glassWhite),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: _isHovered
                  ? (widget.borderColor ?? AppColors.glassBorderGlow)
                  : (widget.borderColor ?? AppColors.glassBorderSubtle),
              width: 1,
            ),
            boxShadow: _isHovered
                ? AppShadows.cardHover
                : (widget.showGlow ? AppShadows.glowPrimary : AppShadows.card),
          ),
          child: widget.child,
        ),
      ),
    );

    if (!isHoverEnabled) {
      return cardChild;
    }

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: AppDurations.fast,
          curve: AppCurves.snappy,
          offset: _isHovered ? const Offset(0, -0.015) : Offset.zero,
          child: cardChild,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/pulse_theme.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final List<Color>? gradientColors;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 1.5,
    this.borderRadius = 16.0,
    this.gradientColors,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ??
        [
          PulseColors.electricCyan.withOpacity(0.8),
          PulseColors.accentPurple.withOpacity(0.6),
          PulseColors.emeraldGrowth.withOpacity(0.8),
          PulseColors.electricCyan.withOpacity(0.8),
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              colors: colors,
              transform: GradientRotation(_controller.value * 2 * 3.14159265),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: Container(
              decoration: BoxDecoration(
                color: PulseColors.cardObsidian.withOpacity(0.85),
                borderRadius: BorderRadius.circular(
                    widget.borderRadius - widget.borderWidth),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

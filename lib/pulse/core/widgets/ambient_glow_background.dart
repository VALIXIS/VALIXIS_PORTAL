import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/pulse_theme.dart';

class AmbientGlowBackground extends StatefulWidget {
  final Widget child;
  final String statusHealth; // 'optimal', 'growth', 'critical'

  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.statusHealth = 'optimal',
  });

  @override
  State<AmbientGlowBackground> createState() => _AmbientGlowBackgroundState();
}

class _AmbientGlowBackgroundState extends State<AmbientGlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _primaryGlowColor {
    switch (widget.statusHealth.toLowerCase()) {
      case 'critical':
        return PulseColors.coralRedAlert;
      case 'growth':
        return PulseColors.emeraldGrowth;
      case 'optimal':
      default:
        return PulseColors.electricCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final opacity = 0.20 + (_pulseAnimation.value * 0.15);

        return Stack(
          children: [
            // Dark obsidian canvas background
            Container(color: PulseColors.backgroundObsidian),

            // Top-left radial glow
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryGlowColor.withOpacity(opacity),
                      _primaryGlowColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-right secondary radial glow
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PulseColors.accentPurple.withOpacity(opacity * 0.7),
                      PulseColors.accentPurple.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Backdrop blur layer for Manus-grade glassmorphism
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(color: Colors.transparent),
            ),

            // Main Content Body
            widget.child,
          ],
        );
      },
    );
  }
}

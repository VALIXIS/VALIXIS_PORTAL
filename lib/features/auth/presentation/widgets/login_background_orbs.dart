import 'package:flutter/material.dart';

/// Ambient glowing gradient background orbs for authentication screens.
class LoginBackgroundOrbs extends StatelessWidget {
  const LoginBackgroundOrbs({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: const _GradientOrb(
                colors: [Color(0x403D5AFE), Color(0x003D5AFE)],
                size: 480,
              ),
            ),
            Positioned(
              bottom: -140,
              left: -120,
              child: const _GradientOrb(
                colors: [Color(0x35651FFF), Color(0x00651FFF)],
                size: 520,
              ),
            ),
            Positioned(
              top: 240,
              left: -80,
              child: const _GradientOrb(
                colors: [Color(0x2500E5FF), Color(0x0000E5FF)],
                size: 340,
              ),
            ),
            Positioned(
              bottom: 120,
              right: -60,
              child: const _GradientOrb(
                colors: [Color(0x203D5AFE), Color(0x003D5AFE)],
                size: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientOrb extends StatelessWidget {
  const _GradientOrb({required this.colors, required this.size});

  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

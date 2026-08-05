import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Background decorative glow orbs for auth screens.
class LoginBackgroundOrbs extends StatelessWidget {
  const LoginBackgroundOrbs({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _Orb(color: AppColors.brandBlue.withAlpha(40), size: 300),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _Orb(color: AppColors.brandPurple.withAlpha(35), size: 350),
            ),
            Positioned(
              top: 200,
              left: -40,
              child: _Orb(color: AppColors.brandCyan.withAlpha(20), size: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

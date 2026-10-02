import 'package:flutter/material.dart';
import '../widgets/ambient_glow_background.dart';

class AmbientRadialShader extends StatelessWidget {
  final Widget child;
  final String statusHealth;

  const AmbientRadialShader({
    super.key,
    required this.child,
    this.statusHealth = 'optimal',
  });

  @override
  Widget build(BuildContext context) {
    return AmbientGlowBackground(
      statusHealth: statusHealth,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

class FluidAnimationCurves {
  static const Curve easeOutBack = Curves.easeOutBack;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
}

class FluidAnimationController {
  static Animation<double> createStaggeredAnimation({
    required AnimationController parent,
    required int index,
    int totalItems = 4,
    Curve curve = Curves.easeOutBack,
  }) {
    final double start = (index / totalItems) * 0.4;
    final double end = (start + 0.6).clamp(0.0, 1.0);

    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(start, end, curve: curve),
      ),
    );
  }
}

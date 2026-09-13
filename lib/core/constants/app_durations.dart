import 'package:flutter/animation.dart';

/// VALIXIS animation duration tokens.
abstract final class AppDurations {
  /// Instant micro-interactions (icon state changes, pips).
  static const Duration instant = Duration(milliseconds: 100);

  /// Fast UI transitions (hover states, button clicks, focus rings).
  static const Duration fast = Duration(milliseconds: 180);

  /// Default transition duration (cards, accordion expansions, badges).
  static const Duration normal = Duration(milliseconds: 280);

  /// Deliberate entrance animations & dialog transitions.
  static const Duration slow = Duration(milliseconds: 450);

  /// Ambient pulse & slow radar rotation.
  static const Duration ambientPulse = Duration(milliseconds: 2400);

  /// Splash logo entrance.
  static const Duration splash = Duration(milliseconds: 900);

  /// Page route transition.
  static const Duration pageTransition = Duration(milliseconds: 320);
}

/// VALIXIS unified easing curves.
abstract final class AppCurves {
  /// Standard smooth deceleration for entering elements.
  static const Curve enter = Curves.easeOutCubic;

  /// Acceleration curve for exiting elements.
  static const Curve exit = Curves.easeInCubic;

  /// High-end mechanical feel for interactive hover & press translations.
  static const Curve snappy = Curves.easeOutQuart;

  /// Fluid organic pulse for status indicators and 3D kinetic rotations.
  static const Curve pulse = Curves.easeInOutSine;
}

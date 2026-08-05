/// VALIXIS animation duration tokens.
abstract final class AppDurations {
  /// Instant micro-interactions (icon state changes).
  static const Duration instant = Duration(milliseconds: 100);

  /// Fast UI transitions (hover, focus).
  static const Duration fast = Duration(milliseconds: 200);

  /// Default transition duration.
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow, deliberate entrance animations.
  static const Duration slow = Duration(milliseconds: 500);

  /// Splash logo entrance.
  static const Duration splash = Duration(milliseconds: 900);

  /// Page route transition.
  static const Duration pageTransition = Duration(milliseconds: 350);
}

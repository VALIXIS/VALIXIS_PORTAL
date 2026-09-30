/// Application-wide constants for VALIXIS BUSINESS OS.
class AppConstants {
  AppConstants._();

  static const String appName = 'VALIXIS';
  static const String appFullName = 'VALIXIS BUSINESS OS';
  static const String appVersion = '1.0.0';
  static const String defaultOrgName = 'VALIXIS Global Enterprise';

  // Navigation Rail metrics
  static const double railExpandedWidth = 250.0;
  static const double railCollapsedWidth = 76.0;

  // Header metrics
  static const double headerHeight = 70.0;
  static const double mobileHeaderHeight = 60.0;

  // Content width constraints
  static const double maxContentWidth = 1440.0;

  // Standard animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
}

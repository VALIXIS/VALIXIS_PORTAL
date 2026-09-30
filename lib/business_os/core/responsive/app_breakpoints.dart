import 'package:flutter/material.dart';

/// Centralized responsive breakpoint definitions for VALIXIS BUSINESS OS.
///
/// Breakpoints:
/// - Mobile:        < 600
/// - Tablet:        600 – 1023
/// - Desktop:       >= 1024
/// - Large Desktop: >= 1440
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double largeDesktopMin = 1440.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletMin;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMin && width < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= largeDesktopMin;

  // Pure width calculations for non-widget / test convenience
  static bool isMobileWidth(double width) => width < tabletMin;
  static bool isTabletWidth(double width) =>
      width >= tabletMin && width < desktopMin;
  static bool isDesktopWidth(double width) => width >= desktopMin;
  static bool isLargeDesktopWidth(double width) => width >= largeDesktopMin;
}

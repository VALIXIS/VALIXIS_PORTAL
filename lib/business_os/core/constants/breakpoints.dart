import 'package:flutter/material.dart';
import '../responsive/app_breakpoints.dart';

export '../responsive/app_breakpoints.dart';

/// Backward-compatibility wrapper for legacy imports
class Breakpoints {
  Breakpoints._();

  static const double mobileMax = AppBreakpoints.mobileMax;
  static const double tabletMin = AppBreakpoints.tabletMin;
  static const double tabletMax = AppBreakpoints.tabletMax;
  static const double desktopMin = AppBreakpoints.desktopMin;
  static const double desktopWideMin = AppBreakpoints.largeDesktopMin;

  static bool isMobile(BuildContext context) =>
      AppBreakpoints.isMobile(context);
  static bool isTablet(BuildContext context) =>
      AppBreakpoints.isTablet(context);
  static bool isDesktop(BuildContext context) =>
      AppBreakpoints.isDesktop(context);
  static bool isWideDesktop(BuildContext context) =>
      AppBreakpoints.isLargeDesktop(context);
}

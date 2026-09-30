import 'package:flutter/material.dart';
import '../../core/responsive/app_breakpoints.dart';

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context);

/// Reusable responsive builder that switches layout according to standard breakpoints.
class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder mobile;
  final ResponsiveWidgetBuilder? tablet;
  final ResponsiveWidgetBuilder desktop;
  final ResponsiveWidgetBuilder? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isLargeDesktop(context) && largeDesktop != null) {
      return largeDesktop!(context);
    }
    if (AppBreakpoints.isDesktop(context)) {
      return desktop(context);
    }
    if (AppBreakpoints.isTablet(context)) {
      return tablet != null ? tablet!(context) : desktop(context);
    }
    return mobile(context);
  }
}

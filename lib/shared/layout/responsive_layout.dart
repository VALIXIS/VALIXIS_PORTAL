import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Resolves a value based on the current screen width.
///
/// Usage:
/// ```dart
/// final padding = context.responsive<double>(
///   mobile: 16,
///   tablet: 24,
///   desktop: 40,
/// );
/// ```
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  bool get isNavRailExtended => screenWidth >= Breakpoints.navRailExtended;

  T responsive<T>({
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet ?? desktop;
    return mobile;
  }
}

/// Widget that builds different layouts per breakpoint.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.desktop) {
      return desktop(context);
    }
    if (width >= Breakpoints.mobile && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

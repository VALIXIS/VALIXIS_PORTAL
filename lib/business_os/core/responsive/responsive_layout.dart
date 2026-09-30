import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

enum DeviceType { mobile, tablet, desktop, largeDesktop }

class ResponsiveLayout {
  ResponsiveLayout._();

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.largeDesktopMin) {
      return DeviceType.largeDesktop;
    } else if (width >= AppBreakpoints.desktopMin) {
      return DeviceType.desktop;
    } else if (width >= AppBreakpoints.tabletMin) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static T valueFor<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

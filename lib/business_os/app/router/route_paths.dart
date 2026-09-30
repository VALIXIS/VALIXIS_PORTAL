import 'package:flutter/material.dart';

/// Centralized route string definitions for VALIXIS BUSINESS OS.
class RoutePaths {
  RoutePaths._();

  static const String root = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String authLoading = '/auth-loading';
  static const String onboarding = '/onboarding';

  // Feature routes
  static const String dashboard = '/dashboard';
  static const String leads = '/leads';
  static const String customers = '/customers';
  static const String operations = '/operations';
  static const String projects = '/projects';
  static const String tasks = '/tasks';
  static const String invoices = '/invoices';
  static const String invoiceBuilder = '/invoices/builder';
  static const String team = '/team';
}

/// Navigation destination descriptor used centrally across ValixisRail,
/// mobile NavigationDrawer, and header breadcrumbs.
class NavigationItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;

  const NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
    this.selectedIcon,
    String? tooltip,
  }) : tooltip = tooltip ?? label;
}

/// Centralized list of primary navigation destinations.
class ValixisNavigation {
  ValixisNavigation._();

  static const List<NavigationItem> items = [
    NavigationItem(
      label: 'Dashboard',
      route: RoutePaths.dashboard,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      tooltip: 'Executive Dashboard & Metrics',
    ),
    NavigationItem(
      label: 'Leads',
      route: RoutePaths.leads,
      icon: Icons.filter_alt_outlined,
      selectedIcon: Icons.filter_alt_rounded,
      tooltip: 'CRM Pipeline & Inquiries',
    ),
    NavigationItem(
      label: 'Customers',
      route: RoutePaths.customers,
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      tooltip: 'Client Accounts & Retention',
    ),
    NavigationItem(
      label: 'Operations',
      route: RoutePaths.operations,
      icon: Icons.hub_outlined,
      selectedIcon: Icons.hub_rounded,
      tooltip: 'Tasks, Workflows & Delivery',
    ),
    NavigationItem(
      label: 'Invoices',
      route: RoutePaths.invoices,
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      tooltip: 'Billing, Payments & Invoices',
    ),
    NavigationItem(
      label: 'Team',
      route: RoutePaths.team,
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge_rounded,
      tooltip: 'Directory & User Access',
    ),
  ];

  static NavigationItem? itemForRoute(String route) {
    for (final item in items) {
      if (route == item.route || route.startsWith('${item.route}/')) {
        return item;
      }
    }
    return null;
  }
}

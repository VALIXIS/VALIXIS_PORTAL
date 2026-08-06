import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../layout/breakpoints.dart';
import 'valixis_rail.dart';

const _allNavItems = [
  NavItem(
    route: AppRoutes.dashboard,
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
  ),
  NavItem(
    route: AppRoutes.tasks,
    label: 'My Tasks',
    icon: Icons.task_alt_outlined,
    selectedIcon: Icons.task_alt_rounded,
  ),
  NavItem(
    route: AppRoutes.managerDashboard,
    label: 'Manager Overview',
    icon: Icons.admin_panel_settings_outlined,
    selectedIcon: Icons.admin_panel_settings_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.managerCreateTask,
    label: 'Create Task',
    icon: Icons.add_task_rounded,
    selectedIcon: Icons.add_task_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.managerAssignments,
    label: 'Assignments',
    icon: Icons.assignment_ind_outlined,
    selectedIcon: Icons.assignment_ind_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.managerReviews,
    label: 'Reviews',
    icon: Icons.rate_review_outlined,
    selectedIcon: Icons.rate_review_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.managerEmployees,
    label: 'Employees',
    icon: Icons.people_outline_rounded,
    selectedIcon: Icons.people_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.profile,
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];

/// Shell layout that wraps main-app screens with role-aware navigation.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  List<NavItem> _visibleItems(UserRole role) {
    if (role.isManager) return _allNavItems;
    return _allNavItems.where((item) => !item.isManagerOnly).toList();
  }

  int _selectedIndex(BuildContext context, List<NavItem> items) {
    final location = GoRouterState.of(context).uri.path;
    final idx = items.indexWhere((i) {
      if (i.route == AppRoutes.dashboard ||
          i.route == AppRoutes.managerDashboard) {
        return location == i.route;
      }
      return location.startsWith(i.route);
    });
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < Breakpoints.mobile;
    final extended = width >= Breakpoints.navRailExtended;
    final userRole = ref.watch(roleProvider).valueOrNull ?? UserRole.employee;
    final items = _visibleItems(userRole);
    final selectedIndex = _selectedIndex(context, items);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.surfaceBase,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: child,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) => context.go(items[i].route),
          backgroundColor: AppColors.surfaceCard,
          indicatorColor: AppColors.brandBlue.withAlpha(40),
          destinations: items
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon, size: 20),
                  selectedIcon: Icon(
                    item.selectedIcon,
                    size: 20,
                    color: AppColors.brandCyan,
                  ),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: Row(
        children: [
          ValixisRail(
            items: items,
            selectedIndex: selectedIndex,
            extended: extended,
            onDestinationSelected: (i) => context.go(items[i].route),
          ),
          const VerticalDivider(
            width: 1,
            color: AppColors.divider,
          ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

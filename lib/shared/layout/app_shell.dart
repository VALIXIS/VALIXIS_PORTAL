import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../layout/breakpoints.dart';

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.isManagerOnly = false,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isManagerOnly;
}

const _allNavItems = [
  _NavItem(
    route: AppRoutes.dashboard,
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
  ),
  _NavItem(
    route: AppRoutes.tasks,
    label: 'My Tasks',
    icon: Icons.task_alt_outlined,
    selectedIcon: Icons.task_alt_rounded,
  ),
  _NavItem(
    route: AppRoutes.managerDashboard,
    label: 'Manager Dashboard',
    icon: Icons.admin_panel_settings_outlined,
    selectedIcon: Icons.admin_panel_settings_rounded,
    isManagerOnly: true,
  ),
  _NavItem(
    route: AppRoutes.managerCreateTask,
    label: 'Create Task',
    icon: Icons.add_task_rounded,
    selectedIcon: Icons.add_task_rounded,
    isManagerOnly: true,
  ),
  _NavItem(
    route: AppRoutes.managerAssignments,
    label: 'Assignments',
    icon: Icons.assignment_ind_outlined,
    selectedIcon: Icons.assignment_ind_rounded,
    isManagerOnly: true,
  ),
  _NavItem(
    route: AppRoutes.managerReviews,
    label: 'Reviews',
    icon: Icons.rate_review_outlined,
    selectedIcon: Icons.rate_review_rounded,
    isManagerOnly: true,
  ),
  _NavItem(
    route: AppRoutes.managerEmployees,
    label: 'Employees',
    icon: Icons.people_outline_rounded,
    selectedIcon: Icons.people_rounded,
    isManagerOnly: true,
  ),
  _NavItem(
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

  List<_NavItem> _visibleItems(UserRole role) {
    if (role.isManager) return _allNavItems;
    return _allNavItems.where((item) => !item.isManagerOnly).toList();
  }

  int _selectedIndex(BuildContext context, List<_NavItem> items) {
    final location = GoRouterState.of(context).uri.path;
    final idx = items.indexWhere((i) {
      if (i.route == AppRoutes.dashboard || i.route == AppRoutes.managerDashboard) {
        return location == i.route;
      }
      return location.startsWith(i.route);
    });
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final extended = width >= Breakpoints.navRailExtended;
    final userRole = ref.watch(roleProvider).valueOrNull ?? UserRole.employee;
    final items = _visibleItems(userRole);
    final selectedIndex = _selectedIndex(context, items);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: Row(
        children: [
          _ValixisRail(
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

class _ValixisRail extends StatelessWidget {
  const _ValixisRail({
    required this.items,
    required this.selectedIndex,
    required this.extended,
    required this.onDestinationSelected,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final bool extended;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.surfaceCard,
      useIndicator: true,
      indicatorColor: const Color(0x223D5AFE),
      minWidth: 68,
      minExtendedWidth: 200,
      leading: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: extended ? AppSpacing.base : AppSpacing.sm,
        ),
        child: extended
            ? Row(
                children: [
                  Image.asset(
                    'assets/logos/valixis_icon.png',
                    width: 28,
                    height: 28,
                    errorBuilder: (context, error, _) => const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.brandBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'VALIXIS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              )
            : Image.asset(
                'assets/logos/valixis_icon.png',
                width: 28,
                height: 28,
                errorBuilder: (context, error, _) => const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.brandBlue,
                  size: 28,
                ),
              ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Consumer(
              builder: (context, ref, _) => IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
                tooltip: 'Sign Out',
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
              ),
            ),
          ),
        ),
      ),
      destinations: items
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon, size: 22),
              selectedIcon: Icon(
                item.selectedIcon,
                size: 22,
                color: AppColors.brandBlue,
              ),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }
}

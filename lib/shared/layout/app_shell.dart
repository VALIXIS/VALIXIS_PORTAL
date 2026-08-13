import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/notifications/presentation/widgets/notification_bell_button.dart';
import '../components/export_center_dialog.dart';
import '../components/global_keyboard_listener.dart';
import '../components/global_search_dialog.dart';
import '../components/user_preferences_dialog.dart';
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
    route: AppRoutes.managerTasks,
    label: 'Manager Tasks',
    icon: Icons.assignment_rounded,
    selectedIcon: Icons.assignment_rounded,
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
    route: AppRoutes.managerAuditLogs,
    label: 'Audit Logs',
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.managerWhatsApp,
    label: 'Direct WhatsApp',
    icon: Icons.chat_bubble_outline_rounded,
    selectedIcon: Icons.chat_bubble_rounded,
    isManagerOnly: true,
  ),
  NavItem(
    route: AppRoutes.profile,
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
  ),
];

/// Shell layout that wraps main-app screens with role-aware navigation and keyboard shortcuts.
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
    final roleAsync = ref.watch(roleProvider);

    if (roleAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceBase,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.brandCyan),
        ),
      );
    }

    final userRole = roleAsync.valueOrNull ?? UserRole.employee;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < Breakpoints.mobile;
    final extended = width >= Breakpoints.navRailExtended;
    final items = _visibleItems(userRole);
    final selectedIndex = _selectedIndex(context, items);

    return GlobalKeyboardListener(
      child: isMobile
          ? Scaffold(
              backgroundColor: AppColors.surfaceBase,
              appBar: AppBar(
                backgroundColor: AppColors.surfaceCard,
                elevation: 0,
                title: const Text(
                  'VALIXIS PORTAL',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: AppColors.brandCyan),
                    onPressed: () => GlobalSearchDialog.show(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.textMuted),
                    onPressed: () => UserPreferencesDialog.show(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: AppColors.textMuted),
                    onPressed: () => ExportCenterDialog.show(context),
                  ),
                  const NotificationBellButton(),
                  const SizedBox(width: 4),
                ],
              ),
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
            )
          : Scaffold(
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
            ),
    );
  }
}

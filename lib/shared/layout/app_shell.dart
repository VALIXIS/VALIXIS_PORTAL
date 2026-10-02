import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../business_os/app/router/route_paths.dart';
import '../../flow/flow_route_paths.dart';
import '../../pulse/pulse_route_paths.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/realtime_sync_service.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/employee/presentation/providers/employee_provider.dart';
import '../../features/manager/presentation/providers/manager_dashboard_provider.dart';
import '../../features/notifications/presentation/widgets/notification_bell_button.dart';
import '../../features/tasks/presentation/providers/tasks_provider.dart';
import '../../shared/models/task.dart';
import '../components/global_search_dialog.dart';
import 'manager_profile_sheet.dart';
import 'valixis_rail.dart';

class _ManagerNavItem {
  const _ManagerNavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
}

/// Executive Command Center App Shell for VALIXIS Manager.
/// Houses the primary manager destinations with real-time telemetry headers.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(roleProvider);
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final employeeAsync = ref.watch(employeeProvider);
    final employee = employeeAsync.valueOrNull;
    final syncState = ref.watch(realtimeSyncProvider);
    final metricsAsync = ref.watch(managerDashboardProvider);
    final myTasksAsync = ref.watch(tasksProvider);

    if (roleAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceBase,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.brandCyan),
        ),
      );
    }

    final userRole = roleAsync.valueOrNull ?? UserRole.employee;
    final isManager = userRole.isManager;

    final nameFromMeta = (user?.userMetadata?['full_name'] as String?) ??
        (user?.userMetadata?['name'] as String?) ??
        (user?.userMetadata?['display_name'] as String?);

    // Validate that employee matches the current authenticated user
    final isMatchingEmployee = employee != null &&
        (user == null ||
            employee.id == user.id ||
            (employee.email.isNotEmpty &&
                user.email != null &&
                employee.email.toLowerCase() == user.email!.toLowerCase()));

    final String displayName;
    if (isMatchingEmployee && employee.fullName.trim().isNotEmpty) {
      displayName = employee.fullName.trim();
    } else if (nameFromMeta != null && nameFromMeta.trim().isNotEmpty) {
      displayName = nameFromMeta.trim();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      final emailLower = user.email!.toLowerCase();
      if (emailLower == 'official.valixis@gmail.com') {
        displayName = 'Subhash';
      } else if (emailLower.contains('jyothsna')) {
        displayName = 'Jyothsna';
      } else {
        final prefix = user.email!.split('@').first;
        displayName = prefix
            .split(RegExp(r'[._-]'))
            .where((s) => s.isNotEmpty)
            .map((s) => s[0].toUpperCase() + s.substring(1))
            .join(' ');
      }
    } else {
      displayName = isManager ? 'Manager' : 'Employee';
    }

    final pendingCount = isManager ? (metricsAsync.valueOrNull?.submittedCount ?? 0) : 0;
    final myActiveCount = myTasksAsync.valueOrNull
            ?.where((t) =>
                t.status != TaskStatus.submitted &&
                t.status != TaskStatus.approved)
            .length ??
        0;

    final location = GoRouterState.of(context).uri.path;
    final isBusinessOs = location.startsWith('/business-os');
    final isFlow = location.startsWith('/flow');
    final isPulse = location.startsWith('/pulse');
    final isPortal = !isBusinessOs && !isFlow && !isPulse;

    final navItems = (isManager && isBusinessOs)
        ? [
            const _ManagerNavItem(
              route: RoutePaths.dashboard,
              label: 'Overview',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
            ),
            const _ManagerNavItem(
              route: RoutePaths.leads,
              label: 'Leads',
              icon: Icons.filter_alt_outlined,
              selectedIcon: Icons.filter_alt_rounded,
            ),
            const _ManagerNavItem(
              route: RoutePaths.customers,
              label: 'Customers',
              icon: Icons.people_outline_rounded,
              selectedIcon: Icons.people_rounded,
            ),
            const _ManagerNavItem(
              route: RoutePaths.invoices,
              label: 'Invoices',
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
            ),
            const _ManagerNavItem(
              route: RoutePaths.team,
              label: 'Team',
              icon: Icons.badge_outlined,
              selectedIcon: Icons.badge_rounded,
            ),
            const _ManagerNavItem(
              route: AppRoutes.profile,
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
            ),
          ]
        : (isManager && isFlow)
            ? [
                const _ManagerNavItem(
                  route: FlowRoutePaths.workflows,
                  label: 'Workflows',
                  icon: Icons.account_tree_outlined,
                  selectedIcon: Icons.account_tree_rounded,
                ),
                const _ManagerNavItem(
                  route: FlowRoutePaths.logs,
                  label: 'Logs',
                  icon: Icons.terminal_outlined,
                  selectedIcon: Icons.terminal_rounded,
                ),
                const _ManagerNavItem(
                  route: FlowRoutePaths.analytics,
                  label: 'Telemetry',
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights_rounded,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.profile,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                ),
              ]
        : (isManager && isPulse)
            ? [
                const _ManagerNavItem(
                  route: PulseRoutePaths.dashboard,
                  label: 'Dashboard',
                  icon: Icons.monitor_heart_outlined,
                  selectedIcon: Icons.monitor_heart_rounded,
                ),
                const _ManagerNavItem(
                  route: PulseRoutePaths.forensic,
                  label: 'Forensic',
                  icon: Icons.biotech_outlined,
                  selectedIcon: Icons.biotech_rounded,
                ),
                const _ManagerNavItem(
                  route: PulseRoutePaths.predictive,
                  label: 'Predictive',
                  icon: Icons.psychology_outlined,
                  selectedIcon: Icons.psychology_rounded,
                ),
                const _ManagerNavItem(
                  route: PulseRoutePaths.anomalies,
                  label: 'Anomalies',
                  icon: Icons.warning_amber_rounded,
                  selectedIcon: Icons.warning_rounded,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.profile,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                ),
              ]
        : isManager
            ? [
                const _ManagerNavItem(
                  route: AppRoutes.managerDashboard,
                  label: 'Overview',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                ),
                _ManagerNavItem(
                  route: AppRoutes.tasks,
                  label: 'My Tasks',
                  icon: Icons.assignment_ind_outlined,
                  selectedIcon: Icons.assignment_ind_rounded,
                  badgeCount: myActiveCount > 0 ? myActiveCount : null,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.managerTasks,
                  label: 'All Tasks',
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.calendar,
                  label: 'Calendar',
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                ),
                _ManagerNavItem(
                  route: AppRoutes.managerReviews,
                  label: 'Reviews',
                  icon: Icons.rate_review_outlined,
                  selectedIcon: Icons.rate_review_rounded,
                  badgeCount: pendingCount > 0 ? pendingCount : null,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.profile,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                ),
              ]
            : [
                const _ManagerNavItem(
                  route: AppRoutes.dashboard,
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                ),
                _ManagerNavItem(
                  route: AppRoutes.tasks,
                  label: 'My Tasks',
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                  badgeCount: myActiveCount > 0 ? myActiveCount : null,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.calendar,
                  label: 'Calendar',
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                ),
                const _ManagerNavItem(
                  route: AppRoutes.profile,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                ),
              ];

    int selectedIndex = 0;
    for (int i = 0; i < navItems.length; i++) {
      if (location == navItems[i].route ||
          (navItems[i].route != AppRoutes.managerDashboard &&
              navItems[i].route != AppRoutes.dashboard &&
              navItems[i].route != RoutePaths.dashboard &&
              location.startsWith(navItems[i].route))) {
        selectedIndex = i;
        break;
      }
    }

    final isOffline = syncState.status == SyncConnectionState.disconnected ||
        syncState.status == SyncConnectionState.error;

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      final railItems = (isManager && isBusinessOs)
          ? [
              const NavItem(
                route: RoutePaths.dashboard,
                label: 'Overview',
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard_rounded,
              ),
              const NavItem(
                route: RoutePaths.leads,
                label: 'Leads & CRM',
                icon: Icons.filter_alt_outlined,
                selectedIcon: Icons.filter_alt_rounded,
              ),
              const NavItem(
                route: RoutePaths.customers,
                label: 'Customers',
                icon: Icons.people_outline_rounded,
                selectedIcon: Icons.people_rounded,
              ),
              const NavItem(
                route: RoutePaths.operations,
                label: 'Operations',
                icon: Icons.hub_outlined,
                selectedIcon: Icons.hub_rounded,
              ),
              const NavItem(
                route: RoutePaths.invoices,
                label: 'Invoices',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
              ),
              const NavItem(
                route: RoutePaths.team,
                label: 'Org Team',
                icon: Icons.badge_outlined,
                selectedIcon: Icons.badge_rounded,
              ),
              const NavItem(
                route: AppRoutes.profile,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
              ),
            ]
          : (isManager && isFlow)
              ? [
                  const NavItem(
                    route: FlowRoutePaths.workflows,
                    label: 'Workflows',
                    icon: Icons.account_tree_outlined,
                    selectedIcon: Icons.account_tree_rounded,
                  ),
                  const NavItem(
                    route: FlowRoutePaths.logs,
                    label: 'Audit Logs',
                    icon: Icons.terminal_outlined,
                    selectedIcon: Icons.terminal_rounded,
                  ),
                  const NavItem(
                    route: FlowRoutePaths.analytics,
                    label: 'Analytics',
                    icon: Icons.insights_outlined,
                    selectedIcon: Icons.insights_rounded,
                  ),
                  const NavItem(
                    route: AppRoutes.profile,
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ]
          : (isManager && isPulse)
              ? [
                  const NavItem(
                    route: PulseRoutePaths.dashboard,
                    label: 'Dashboard',
                    icon: Icons.monitor_heart_outlined,
                    selectedIcon: Icons.monitor_heart_rounded,
                  ),
                  const NavItem(
                    route: PulseRoutePaths.forensic,
                    label: 'Forensic Pivot',
                    icon: Icons.biotech_outlined,
                    selectedIcon: Icons.biotech_rounded,
                  ),
                  const NavItem(
                    route: PulseRoutePaths.predictive,
                    label: 'Predictive AI',
                    icon: Icons.psychology_outlined,
                    selectedIcon: Icons.psychology_rounded,
                  ),
                  const NavItem(
                    route: PulseRoutePaths.anomalies,
                    label: 'Anomalies',
                    icon: Icons.warning_amber_rounded,
                    selectedIcon: Icons.warning_rounded,
                  ),
                  const NavItem(
                    route: AppRoutes.profile,
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ]
          : isManager
              ? [
                  const NavItem(
                    route: AppRoutes.managerDashboard,
                    label: 'Overview',
                    icon: Icons.grid_view_outlined,
                    selectedIcon: Icons.grid_view_rounded,
                  ),
                  NavItem(
                    route: AppRoutes.tasks,
                    label: 'My Tasks',
                    icon: Icons.assignment_ind_outlined,
                    selectedIcon: Icons.assignment_ind_rounded,
                    badgeCount: myActiveCount > 0 ? myActiveCount : null,
                  ),
                  const NavItem(
                    route: AppRoutes.managerTasks,
                    label: 'All Tasks',
                    icon: Icons.assignment_outlined,
                    selectedIcon: Icons.assignment_rounded,
                  ),
                  const NavItem(
                    route: AppRoutes.calendar,
                    label: 'Calendar',
                    icon: Icons.calendar_month_outlined,
                    selectedIcon: Icons.calendar_month_rounded,
                  ),
                  NavItem(
                    route: AppRoutes.managerReviews,
                    label: 'Reviews & PRs',
                    icon: Icons.rate_review_outlined,
                    selectedIcon: Icons.rate_review_rounded,
                    badgeCount: pendingCount > 0 ? pendingCount : null,
                  ),
                  const NavItem(
                    route: AppRoutes.managerEmployees,
                    label: 'Team',
                    icon: Icons.people_outline_rounded,
                    selectedIcon: Icons.people_rounded,
                  ),
                  const NavItem(
                    route: AppRoutes.managerAuditLogs,
                    label: 'Audit Logs',
                    icon: Icons.fact_check_outlined,
                    selectedIcon: Icons.fact_check_rounded,
                  ),
                  const NavItem(
                    route: AppRoutes.profile,
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ]
              : [
                  const NavItem(
                    route: AppRoutes.dashboard,
                    label: 'Dashboard',
                    icon: Icons.grid_view_outlined,
                    selectedIcon: Icons.grid_view_rounded,
                  ),
                  NavItem(
                    route: AppRoutes.tasks,
                    label: 'My Tasks',
                    icon: Icons.assignment_outlined,
                    selectedIcon: Icons.assignment_rounded,
                    badgeCount: myActiveCount > 0 ? myActiveCount : null,
                  ),
                  const NavItem(
                    route: AppRoutes.calendar,
                    label: 'Calendar',
                    icon: Icons.calendar_month_outlined,
                    selectedIcon: Icons.calendar_month_rounded,
                  ),
                  const NavItem(
                    route: AppRoutes.profile,
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ];

      int selectedRailIndex = 0;
      for (int i = 0; i < railItems.length; i++) {
        if (location == railItems[i].route ||
            (railItems[i].route != AppRoutes.managerDashboard &&
                railItems[i].route != AppRoutes.dashboard &&
                railItems[i].route != RoutePaths.dashboard &&
                railItems[i].route != FlowRoutePaths.workflows &&
                railItems[i].route != PulseRoutePaths.dashboard &&
                location.startsWith(railItems[i].route))) {
          selectedRailIndex = i;
          break;
        }
      }

      final activeSectionLabel = selectedRailIndex < railItems.length
          ? railItems[selectedRailIndex].label
          : (isPulse
              ? 'DASHBOARD'
              : isFlow
                  ? 'WORKFLOWS'
                  : (isBusinessOs ? 'OVERVIEW' : (isManager ? 'OVERVIEW' : 'DASHBOARD')));
      final rootBreadcrumb = isPulse
          ? 'VALIXIS PULSE • TELEMETRY'
          : isFlow
              ? 'VALIXIS FLOW • AUTOMATION'
              : isBusinessOs
                  ? 'VALIXIS BUSINESS OS • EXECUTIVE'
                  : (isManager ? 'VALIXIS PORTAL • MANAGER' : 'VALIXIS PORTAL • EMPLOYEE');

      return Scaffold(
        backgroundColor: AppColors.surfaceBase,
        body: Row(
          children: [
            ValixisRail(
              items: railItems,
              selectedIndex: selectedRailIndex,
              extended: MediaQuery.of(context).size.width >= 1150,
              onDestinationSelected: (i) => context.go(railItems[i].route),
            ),
            Expanded(
              child: Column(
                children: [
                  // ── Top Command Header ─────────────────────────────────
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Breadcrumb
                        Row(
                          children: [
                            Text(
                              rootBreadcrumb,
                              style: AppTypography.telemetryHeader(
                                size: 10,
                                color: AppColors.textMuted,
                                spacing: 1.0,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '/',
                                style: TextStyle(color: AppColors.divider, fontSize: 13),
                              ),
                            ),
                            Text(
                              activeSectionLabel.toUpperCase(),
                              style: AppTypography.telemetryHeader(
                                size: 11,
                                color: AppColors.brandCyan,
                                spacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // ── Valixis Suite Segmented Mode Switcher (MANAGERS ONLY) ──
                        if (isManager) ...[
                          Container(
                            height: 36,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.divider, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── ⚡ VALIXIS PORTAL ──
                                InkWell(
                                  borderRadius: BorderRadius.circular(7),
                                  onTap: () {
                                    if (!isPortal) {
                                      context.go(AppRoutes.managerDashboard);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: isPortal ? AppColors.brandGradient : null,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: isPortal
                                          ? [
                                              BoxShadow(
                                                color: AppColors.brandCyan.withValues(alpha: 0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bolt_rounded,
                                          size: 14,
                                          color: isPortal ? Colors.white : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'PORTAL',
                                          style: TextStyle(
                                            color: isPortal ? Colors.white : AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // ── 💼 BUSINESS OS ──
                                InkWell(
                                  borderRadius: BorderRadius.circular(7),
                                  onTap: () {
                                    if (!isBusinessOs) {
                                      context.go(RoutePaths.dashboard);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: isBusinessOs
                                          ? const LinearGradient(
                                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: isBusinessOs
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.business_center_rounded,
                                          size: 14,
                                          color: isBusinessOs ? Colors.white : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'BUSINESS OS',
                                          style: TextStyle(
                                            color: isBusinessOs ? Colors.white : AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // ── 🔄 FLOW ──
                                InkWell(
                                  borderRadius: BorderRadius.circular(7),
                                  onTap: () {
                                    if (!isFlow) {
                                      context.go(FlowRoutePaths.workflows);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: isFlow
                                          ? const LinearGradient(
                                              colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: isFlow
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.account_tree_rounded,
                                          size: 14,
                                          color: isFlow ? Colors.white : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'FLOW',
                                          style: TextStyle(
                                            color: isFlow ? Colors.white : AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // ── 📈 PULSE ──
                                InkWell(
                                  borderRadius: BorderRadius.circular(7),
                                  onTap: () {
                                    if (!isPulse) {
                                      context.go(PulseRoutePaths.dashboard);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: isPulse
                                          ? const LinearGradient(
                                              colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: isPulse
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.monitor_heart_rounded,
                                          size: 14,
                                          color: isPulse ? Colors.white : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'PULSE',
                                          style: TextStyle(
                                            color: isPulse ? Colors.white : AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],

                        // Live Sync Status Pill
                        _SyncStatusBadge(syncState: syncState),
                        const SizedBox(width: AppSpacing.md),

                        // Notification Bell
                        const NotificationBellButton(),
                        const SizedBox(width: AppSpacing.sm),

                        // Manager / User Profile Node with Official Logo
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => ManagerProfileSheet.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.brandCyan.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logos/valixis_icon.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.bolt_rounded,
                                        color: AppColors.brandCyan,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  displayName,
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isManager ? AppColors.brandPurple : AppColors.brandBlue).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: (isManager ? AppColors.brandPurple : AppColors.brandBlue).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    isManager ? 'MANAGER' : 'EMPLOYEE',
                                    style: AppTypography.telemetryHeader(
                                      size: 8,
                                      color: isManager ? AppColors.brandPurple : AppColors.brandCyan,
                                      spacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Offline Alert Strip
                  if (isOffline)
                    Material(
                      color: AppColors.error.withValues(alpha: 0.15),
                      child: InkWell(
                        onTap: () => ref.read(realtimeSyncProvider.notifier).forceRefresh(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.error, width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.error),
                              SizedBox(width: 8),
                              Text(
                                'Offline Mode • Tap to reconnect',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Main View Content with Background Gradient
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
          ],
        ),
      );
    }

    // ── Mobile / Small Tablet View ─────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.md,
        title: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.brandGradient,
              ),
              child: Center(
                child: Image.asset(
                  'assets/logos/valixis_icon.png',
                  height: 16,
                  width: 16,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isPulse
                  ? 'VALIXIS PULSE'
                  : isFlow
                      ? 'VALIXIS FLOW'
                      : isBusinessOs
                          ? 'VALIXIS BUSINESS OS'
                          : 'VALIXIS PORTAL',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: (isManager ? AppColors.brandPurple : AppColors.brandBlue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: (isManager ? AppColors.brandPurple : AppColors.brandBlue).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                isPulse
                    ? 'TELEMETRY'
                    : isFlow
                        ? 'AUTOMATION'
                        : isBusinessOs
                            ? 'EXECUTIVE'
                            : (isManager ? 'MANAGER' : 'EMPLOYEE'),
                style: AppTypography.telemetryHeader(
                  size: 7,
                  color: isManager ? AppColors.brandPurple : AppColors.brandCyan,
                  spacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          _SyncStatusBadge(syncState: syncState),
          const SizedBox(width: AppSpacing.xs),
          if (isManager)
            PopupMenuButton<String>(
              icon: Icon(
                isPulse
                    ? Icons.monitor_heart_rounded
                    : isFlow
                        ? Icons.account_tree_rounded
                        : isBusinessOs
                            ? Icons.business_center_rounded
                            : Icons.bolt_rounded,
                color: isPulse
                    ? const Color(0xFF10B981)
                    : isFlow
                        ? const Color(0xFF6366F1)
                        : isBusinessOs
                            ? const Color(0xFF8B5CF6)
                            : AppColors.brandCyan,
                size: 20,
              ),
              tooltip: 'Valixis Executive Suite Switcher',
              color: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              onSelected: (route) => context.go(route),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: AppRoutes.managerDashboard,
                  child: Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: AppColors.brandCyan, size: 16),
                      SizedBox(width: 8),
                      Text('VALIXIS PORTAL', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: RoutePaths.dashboard,
                  child: Row(
                    children: [
                      Icon(Icons.business_center_rounded, color: Color(0xFF8B5CF6), size: 16),
                      SizedBox(width: 8),
                      Text('BUSINESS OS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: FlowRoutePaths.workflows,
                  child: Row(
                    children: [
                      Icon(Icons.account_tree_rounded, color: Color(0xFF6366F1), size: 16),
                      SizedBox(width: 8),
                      Text('FLOW AUTOMATION', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: PulseRoutePaths.dashboard,
                  child: Row(
                    children: [
                      Icon(Icons.monitor_heart_rounded, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 8),
                      Text('PULSE TELEMETRY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.brandCyan, size: 20),
            tooltip: 'Search',
            onPressed: () => GlobalSearchDialog.show(context),
          ),
          IconButton(
            icon: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandCyan.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logos/valixis_icon.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.brandCyan,
                    size: 16,
                  ),
                ),
              ),
            ),
            tooltip: isManager ? 'Manager Profile' : 'Profile',
            onPressed: () => ManagerProfileSheet.show(context),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            Material(
              color: AppColors.error.withValues(alpha: 0.15),
              child: InkWell(
                onTap: () => ref.read(realtimeSyncProvider.notifier).forceRefresh(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.error, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Offline Mode • Tap to reconnect',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceCard,
          indicatorColor: AppColors.brandBlue.withValues(alpha: 0.25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              color: isSelected ? AppColors.brandCyan : AppColors.textMuted,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) => context.go(navItems[i].route),
          height: 64,
          destinations: navItems.map((item) {
            Widget icon = Icon(item.icon, size: 22, color: AppColors.textMuted);
            Widget selectedIcon = Icon(item.selectedIcon, size: 22, color: AppColors.brandCyan);

            if (item.badgeCount != null && item.badgeCount! > 0) {
              icon = Badge(
                label: Text(
                  item.badgeCount.toString(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                ),
                backgroundColor: AppColors.brandCyan,
                textColor: AppColors.surfaceBase,
                child: icon,
              );
              selectedIcon = Badge(
                label: Text(
                  item.badgeCount.toString(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                ),
                backgroundColor: AppColors.brandCyan,
                textColor: AppColors.surfaceBase,
                child: selectedIcon,
              );
            }

            return NavigationDestination(
              icon: icon,
              selectedIcon: selectedIcon,
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  const _SyncStatusBadge({required this.syncState});

  final RealtimeSyncState syncState;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (syncState.status) {
      SyncConnectionState.connected => (AppColors.success, 'SYSTEM ONLINE'),
      SyncConnectionState.connecting => (AppColors.warning, 'SYNCING'),
      SyncConnectionState.disconnected => (AppColors.textMuted, 'OFFLINE'),
      SyncConnectionState.error => (AppColors.error, 'LINK ERROR'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.telemetryHeader(
              size: 9,
              color: color,
              spacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}


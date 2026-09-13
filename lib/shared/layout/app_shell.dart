import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/realtime_sync_service.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/manager/presentation/providers/manager_dashboard_provider.dart';
import '../../features/notifications/presentation/widgets/notification_bell_button.dart';
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
    final syncState = ref.watch(realtimeSyncProvider);
    final metricsAsync = ref.watch(managerDashboardProvider);

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
    final pendingCount = isManager ? (metricsAsync.valueOrNull?.submittedCount ?? 0) : 0;

    final navItems = isManager
        ? [
            const _ManagerNavItem(
              route: AppRoutes.managerDashboard,
              label: 'Overview',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
            ),
            const _ManagerNavItem(
              route: AppRoutes.managerTasks,
              label: 'Tasks',
              icon: Icons.assignment_outlined,
              selectedIcon: Icons.assignment_rounded,
            ),
            _ManagerNavItem(
              route: AppRoutes.managerReviews,
              label: 'Reviews',
              icon: Icons.rate_review_outlined,
              selectedIcon: Icons.rate_review_rounded,
              badgeCount: pendingCount > 0 ? pendingCount : null,
            ),
            const _ManagerNavItem(
              route: AppRoutes.managerAuditLogs,
              label: 'Audit Logs',
              icon: Icons.fact_check_outlined,
              selectedIcon: Icons.fact_check_rounded,
            ),
          ]
        : [
            const _ManagerNavItem(
              route: AppRoutes.dashboard,
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
            ),
            const _ManagerNavItem(
              route: AppRoutes.tasks,
              label: 'My Tasks',
              icon: Icons.assignment_outlined,
              selectedIcon: Icons.assignment_rounded,
            ),
            const _ManagerNavItem(
              route: AppRoutes.profile,
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
            ),
          ];

    final location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    for (int i = 0; i < navItems.length; i++) {
      if (location == navItems[i].route ||
          (navItems[i].route != AppRoutes.managerDashboard &&
              navItems[i].route != AppRoutes.dashboard &&
              location.startsWith(navItems[i].route))) {
        selectedIndex = i;
        break;
      }
    }

    final isOffline = syncState.status == SyncConnectionState.disconnected ||
        syncState.status == SyncConnectionState.error;

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      final railItems = isManager
          ? [
              const NavItem(
                route: AppRoutes.managerDashboard,
                label: 'Overview',
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
              ),
              const NavItem(
                route: AppRoutes.managerTasks,
                label: 'Tasks Workspace',
                icon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment_rounded,
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
                label: 'Personnel',
                icon: Icons.people_outline_rounded,
                selectedIcon: Icons.people_rounded,
              ),
              const NavItem(
                route: AppRoutes.managerAuditLogs,
                label: 'Audit Stream',
                icon: Icons.fact_check_outlined,
                selectedIcon: Icons.fact_check_rounded,
              ),
              const NavItem(
                route: AppRoutes.profile,
                label: 'System Profile',
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
              const NavItem(
                route: AppRoutes.tasks,
                label: 'My Tasks',
                icon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment_rounded,
              ),
              const NavItem(
                route: AppRoutes.profile,
                label: 'System Profile',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
              ),
            ];

      int selectedRailIndex = 0;
      for (int i = 0; i < railItems.length; i++) {
        if (location == railItems[i].route ||
            (railItems[i].route != AppRoutes.managerDashboard &&
                railItems[i].route != AppRoutes.dashboard &&
                location.startsWith(railItems[i].route))) {
          selectedRailIndex = i;
          break;
        }
      }

      final activeSectionLabel = selectedRailIndex < railItems.length
          ? railItems[selectedRailIndex].label
          : (isManager ? 'OVERVIEW' : 'DASHBOARD');
      final rootBreadcrumb = isManager ? 'CORE' : 'PORTAL';

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
                  // ── Top Telemetry Command Header ───────────────────────
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
                        // Telemetry Breadcrumb
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

                        // Live Sync Status Pill
                        _SyncStatusBadge(syncState: syncState),
                        const SizedBox(width: AppSpacing.md),

                        // Notification Bell
                        const NotificationBellButton(),
                        const SizedBox(width: AppSpacing.sm),

                        // Manager / User Profile Command Node
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
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      (user?.email?.isNotEmpty == true
                                              ? user!.email!.substring(0, 1)
                                              : (isManager ? 'M' : 'E'))
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  user?.email?.split('@').first ??
                                      (isManager ? 'Manager' : 'Employee'),
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
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
                                'Offline Mode • Tap to reconnect telemetry link',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'VALIXIS',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'COMMAND OS',
                  style: AppTypography.telemetryHeader(
                    size: 8,
                    color: AppColors.brandCyan,
                    spacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _SyncStatusBadge(syncState: syncState),
          const SizedBox(width: AppSpacing.xs),
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
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandCyan.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  (user?.email?.isNotEmpty == true
                          ? user!.email!.substring(0, 1)
                          : (isManager ? 'M' : 'E'))
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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
      SyncConnectionState.connected => (AppColors.success, 'TELEMETRY LIVE'),
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


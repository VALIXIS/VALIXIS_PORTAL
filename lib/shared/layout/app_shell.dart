import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/network/realtime_sync_service.dart';
import '../../features/auth/domain/role_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/role_provider.dart';
import '../../features/manager/presentation/providers/manager_dashboard_provider.dart';
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

/// Executive Mobile App Shell tailored for VALIXIS Manager.
/// Houses the 4 primary manager destinations: Overview, Tasks, Reviews, and Audit Logs.
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
    if (!userRole.isManager) {
      // If a non-manager account somehow reached the shell, show restricted state
      return Scaffold(
        backgroundColor: AppColors.surfaceBase,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'VALIXIS Manager Access Restricted',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Your account does not possess manager authorization.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandBlue),
                  onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                  child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pendingCount = metricsAsync.valueOrNull?.submittedCount ?? 0;

    final navItems = [
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
    ];

    final location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    for (int i = 0; i < navItems.length; i++) {
      if (location == navItems[i].route ||
          (navItems[i].route != AppRoutes.managerDashboard &&
              location.startsWith(navItems[i].route))) {
        selectedIndex = i;
        break;
      }
    }

    final isOffline = syncState.status == SyncConnectionState.disconnected ||
        syncState.status == SyncConnectionState.error;

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      final railItems = [
        const NavItem(
          route: AppRoutes.managerDashboard,
          label: 'Dashboard',
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view_rounded,
        ),
        const NavItem(
          route: AppRoutes.managerTasks,
          label: 'Manager Tasks',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment_rounded,
        ),
        NavItem(
          route: AppRoutes.managerReviews,
          label: 'Reviews',
          icon: Icons.rate_review_outlined,
          selectedIcon: Icons.rate_review_rounded,
        ),
        const NavItem(
          route: AppRoutes.managerEmployees,
          label: 'Employees',
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
      ];

      int selectedRailIndex = 0;
      for (int i = 0; i < railItems.length; i++) {
        if (location == railItems[i].route ||
            (railItems[i].route != AppRoutes.managerDashboard &&
                location.startsWith(railItems[i].route))) {
          selectedRailIndex = i;
          break;
        }
      }

      return Scaffold(
        backgroundColor: AppColors.surfaceBase,
        body: Row(
          children: [
            ValixisRail(
              items: railItems,
              selectedIndex: selectedRailIndex,
              extended: MediaQuery.of(context).size.width >= 1100,
              onDestinationSelected: (i) => context.go(railItems[i].route),
            ),
            Expanded(
              child: Column(
                children: [
                  if (isOffline)
                    Material(
                      color: AppColors.error.withAlpha(40),
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
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.md,
        title: Row(
          children: [
            Image.asset(
              'assets/logos/valixis_icon.png',
              height: 28,
              width: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.hub_rounded,
                color: AppColors.brandCyan,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VALIXIS',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'MANAGER',
                  style: TextStyle(
                    color: AppColors.brandCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Live Sync Status Pill
          _SyncStatusBadge(syncState: syncState),
          const SizedBox(width: AppSpacing.xs),
          // Manager Profile / Logout Sheet Trigger
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandCyan.withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  (user?.email?.isNotEmpty == true
                          ? user!.email!.substring(0, 1)
                          : 'M')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            tooltip: 'Manager Profile & Sync',
            onPressed: () => ManagerProfileSheet.show(context),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            Material(
              color: AppColors.error.withAlpha(40),
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
          indicatorColor: AppColors.brandBlue.withAlpha(50),
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
      SyncConnectionState.connected => (AppColors.success, 'LIVE'),
      SyncConnectionState.connecting => (AppColors.warning, 'SYNC'),
      SyncConnectionState.disconnected => (AppColors.textMuted, 'OFFLINE'),
      SyncConnectionState.error => (AppColors.error, 'ERROR'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60), width: 1),
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
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

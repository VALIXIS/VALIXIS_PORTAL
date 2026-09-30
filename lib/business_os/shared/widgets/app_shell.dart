import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_header.dart';
import 'valixis_rail.dart';

import '../../features/ai_assistant/presentation/widgets/ai_assistant_panel.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/notifications/presentation/widgets/notification_drawer.dart';

/// Main authenticated application shell for VALIXIS BUSINESS OS.
class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRailCollapsed = false;

  void _toggleRailCollapse() {
    setState(() {
      _isRailCollapsed = !_isRailCollapsed;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _handleSignOut() {
    ref.read(authNotifierProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    String currentPath = RoutePaths.dashboard;
    try {
      currentPath = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      // Graceful fallback for widget tests and previews
    }
    final isMobile = AppBreakpoints.isMobile(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final currentUser = ref.watch(currentUserProvider);

    // On tablet, collapse by default unless user explicitly expanded
    final effectiveCollapsed = isTablet || _isRailCollapsed;

    // Realtime Toast Notifications Alert Listener
    ref.listen<NotificationsState>(notificationsProvider, (previous, next) {
      final item = next.latestRealtimeItem;
      if (item != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              backgroundColor: AppColors.surfaceElevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.title.copyWith(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item.message,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              action: (item.link != null && item.link!.isNotEmpty)
                  ? SnackBarAction(
                      label: 'VIEW',
                      textColor: AppColors.primary,
                      onPressed: () {
                        ref
                            .read(notificationsProvider.notifier)
                            .markAsRead(item.id);
                        try {
                          context.go(item.link!);
                        } catch (e) {
                          debugPrint('Error navigating to ${item.link}: $e');
                        }
                      },
                    )
                  : null,
            ),
          );
          ref.read(notificationsProvider.notifier).clearLatestRealtimeItem();
        });
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile ? _buildMobileDrawer(context, currentPath) : null,
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Desktop & Tablet Navigation Rail
              if (!isMobile)
                ValixisRail(
                  isCollapsed: effectiveCollapsed,
                  onToggleCollapse: _toggleRailCollapse,
                  currentRoute: currentPath,
                  currentUser: currentUser,
                ),

              // Main Content Area with Global Header & Active Router Page
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppHeader(
                      currentRoute: currentPath,
                      onOpenDrawer: _openDrawer,
                      currentUser: currentUser,
                      onSignOut: _handleSignOut,
                    ),
                    Expanded(child: SelectionArea(child: widget.child)),
                  ],
                ),
              ),
            ],
          ),
          const NotificationDrawer(),
          const AIAssistantPanel(),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, String currentPath) {
    final currentUser = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 16,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Brand Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'V',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VALIXIS',
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'BUSINESS OS',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // Centralized navigation destination list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ValixisNavigation.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = ValixisNavigation.items[index];
                  final isActive =
                      currentPath == item.route ||
                      currentPath.startsWith('${item.route}/');

                  return ListTile(
                    leading: Icon(
                      isActive ? (item.selectedIcon ?? item.icon) : item.icon,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(
                      item.label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor: AppColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: isActive
                          ? BorderSide(color: AppColors.glassBorderActive)
                          : BorderSide.none,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(item.route);
                    },
                  );
                },
              ),
            ),

            Divider(color: AppColors.border, height: 1),

            // User Info & Sign Out Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surfaceElevated,
                    child: Text(
                      (currentUser?.displayName ?? 'VX')
                          .substring(0, 2)
                          .toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.displayName ?? 'VALIXIS Admin',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentUser?.role ?? 'Enterprise Admin',
                          style: AppTypography.caption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    tooltip: 'Sign Out',
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handleSignOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

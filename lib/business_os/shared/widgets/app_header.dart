import 'package:flutter/material.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../features/ai_assistant/presentation/widgets/ai_assistant_button.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';
import '../models/app_user.dart';

class AppHeader extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onOpenDrawer;
  final AppUser? currentUser;
  final VoidCallback? onSignOut;

  const AppHeader({
    super.key,
    required this.currentRoute,
    this.onOpenDrawer,
    this.currentUser,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final user = currentUser ?? AppUser.devAdmin();
    final navItem = ValixisNavigation.itemForRoute(currentRoute);
    final title = navItem?.label ?? 'Dashboard';

    return Container(
      height: isMobile
          ? AppConstants.mobileHeaderHeight
          : AppConstants.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Mobile Menu Drawer Button
          if (isMobile)
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: onOpenDrawer,
              tooltip: 'Open navigation menu',
            ),

          if (isMobile) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTypography.title.copyWith(fontSize: 16)),
          ] else ...[
            // Desktop & Tablet: Breadcrumb and Title
            Row(
              children: [
                Text(
                  'VALIXIS',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '/',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],

          const Spacer(),

          // Desktop search preview
          if (!isMobile && AppBreakpoints.isDesktop(context)) ...[
            Container(
              width: 240,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text('Quick search...', style: AppTypography.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Live status badge on tablet & desktop
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: AppTypography.label.copyWith(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],

          // AI Executive Assistant Action
          const AiAssistantButton(),

          const SizedBox(width: 8),

          // Notifications Center Bell
          const NotificationBell(),

          const SizedBox(width: 8),

          // User Profile & Account Menu
          PopupMenuButton<String>(
            tooltip: 'Account Options',
            color: AppColors.surfaceElevated,
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            onSelected: (value) {
              if (value == 'logout' && onSignOut != null) {
                onSignOut!();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: AppTypography.title.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppTypography.caption),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Organization Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Text(
                    user.displayName
                        .substring(0, user.displayName.length.clamp(1, 2))
                        .toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Text(
                    user.displayName,
                    style: AppTypography.bodySmall.copyWith(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/notifications/presentation/widgets/notification_bell_button.dart';
import '../components/export_center_dialog.dart';
import '../components/global_search_dialog.dart';
import '../components/user_preferences_dialog.dart';

class NavItem {
  const NavItem({
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

class ValixisRail extends StatelessWidget {
  const ValixisRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.extended,
    required this.onDestinationSelected,
  });

  final List<NavItem> items;
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
      indicatorColor: AppColors.brandBlue.withAlpha(40),
      minWidth: 68,
      minExtendedWidth: 200,
      leading: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: extended ? AppSpacing.base : AppSpacing.sm,
        ),
        child: Column(
          children: [
            extended
                ? Row(
                    children: [
                      Image.asset(
                        'assets/logos/valixis_icon.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, _) => const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.brandCyan,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'VALIXIS',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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
                      color: AppColors.brandCyan,
                      size: 28,
                    ),
                  ),
            const SizedBox(height: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.brandCyan),
              tooltip: 'Global Search (Ctrl+K)',
              onPressed: () => GlobalSearchDialog.show(context),
            ),
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppColors.textMuted),
                  tooltip: 'Preferences',
                  onPressed: () => UserPreferencesDialog.show(context),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: AppColors.textMuted),
                  tooltip: 'Export Center',
                  onPressed: () => ExportCenterDialog.show(context),
                ),
                const NotificationBellButton(),
                const SizedBox(height: AppSpacing.xs),
                Consumer(
                  builder: (context, ref, _) => IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textMuted),
                    tooltip: 'Sign Out',
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signOut(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      destinations: items
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon, size: 20),
              selectedIcon: Icon(
                item.selectedIcon,
                size: 20,
                color: AppColors.brandCyan,
              ),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }
}

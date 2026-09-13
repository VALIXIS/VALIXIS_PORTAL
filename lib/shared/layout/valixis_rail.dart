import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_durations.dart';
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
    this.badgeCount,
    this.isManagerOnly = false,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
  final bool isManagerOnly;
}

/// Advanced Futuristic Enterprise Navigation Rail for VALIXIS Command Center.
class ValixisRail extends StatefulWidget {
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
  State<ValixisRail> createState() => _ValixisRailState();
}

class _ValixisRailState extends State<ValixisRail> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final width = widget.extended ? 230.0 : 72.0;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.snappy,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          right: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand Header ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: widget.extended ? AppSpacing.md : AppSpacing.sm,
            ),
            child: widget.extended
                ? Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandCyan.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/logos/valixis_icon.png',
                            width: 18,
                            height: 18,
                            errorBuilder: (context, error, _) => const Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'VALIXIS',
                                style: AppTypography.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.brandCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'COMMAND OS',
                            style: AppTypography.telemetryHeader(
                              size: 9,
                              color: AppColors.brandCyan,
                              spacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandCyan.withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/logos/valixis_icon.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, _) => const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          // ── Quick Command Trigger ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.extended ? AppSpacing.md : AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => GlobalSearchDialog.show(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.extended ? 10 : 8,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: widget.extended
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.brandCyan,
                          size: 16,
                        ),
                        if (widget.extended) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Quick Jump',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.extended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          'Ctrl+K',
                          style: AppTypography.mono(
                            size: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Navigation Destinations ───────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: widget.extended ? AppSpacing.sm : 8,
                vertical: AppSpacing.xs,
              ),
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.selectedIndex == index;
                final isHovered = _hoveredIndex == index;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: InkWell(
                    onTap: () => widget.onDestinationSelected(index),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      curve: AppCurves.snappy,
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.extended ? 12 : 0,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.activeTabGradient
                            : (isHovered
                                ? const LinearGradient(
                                    colors: [
                                      Color(0x15FFFFFF),
                                      Color(0x05FFFFFF),
                                    ],
                                  )
                                : null),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? const Border(
                                left: BorderSide(
                                  color: AppColors.brandCyan,
                                  width: 3,
                                ),
                              )
                            : null,
                      ),
                      child: widget.extended
                          ? Row(
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  size: 18,
                                  color: isSelected
                                      ? AppColors.brandCyan
                                      : (isHovered
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : (isHovered
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary),
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.badgeCount != null &&
                                    item.badgeCount! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandCyan,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${item.badgeCount}',
                                      style: AppTypography.mono(
                                        size: 10,
                                        weight: FontWeight.w800,
                                        color: AppColors.surfaceBase,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 20,
                                    color: isSelected
                                        ? AppColors.brandCyan
                                        : (isHovered
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary),
                                  ),
                                  if (item.badgeCount != null &&
                                      item.badgeCount! > 0)
                                    Positioned(
                                      top: -4,
                                      right: -6,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.brandCyan,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Footer Control Center ─────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.extended ? AppSpacing.md : AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: widget.extended
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        color: AppColors.textMuted,
                        tooltip: 'System Preferences',
                        onPressed: () => UserPreferencesDialog.show(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        color: AppColors.textMuted,
                        tooltip: 'Export Center',
                        onPressed: () => ExportCenterDialog.show(context),
                      ),
                      const NotificationBellButton(),
                      Consumer(
                        builder: (context, ref, _) => IconButton(
                          icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                          color: AppColors.textMuted,
                          tooltip: 'Terminate Session',
                          onPressed: () =>
                              ref.read(authNotifierProvider.notifier).signOut(),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        color: AppColors.textMuted,
                        tooltip: 'Preferences',
                        onPressed: () => UserPreferencesDialog.show(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        color: AppColors.textMuted,
                        tooltip: 'Export Center',
                        onPressed: () => ExportCenterDialog.show(context),
                      ),
                      const NotificationBellButton(),
                      Consumer(
                        builder: (context, ref, _) => IconButton(
                          icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                          color: AppColors.textMuted,
                          tooltip: 'Sign Out',
                          onPressed: () =>
                              ref.read(authNotifierProvider.notifier).signOut(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}


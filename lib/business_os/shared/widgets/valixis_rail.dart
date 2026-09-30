import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';

class ValixisRail extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final String currentRoute;
  final AppUser? currentUser;

  const ValixisRail({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.currentRoute,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.defaultAnimationDuration,
      curve: Curves.easeInOut,
      width: isCollapsed
          ? AppConstants.railCollapsedWidth
          : AppConstants.railExpandedWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand Header Area
          _buildBrandHeader(),

          const SizedBox(height: 12),

          // Centralized Navigation Items
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 8 : 12,
                vertical: 4,
              ),
              itemCount: ValixisNavigation.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = ValixisNavigation.items[index];
                final isActive =
                    currentRoute == item.route ||
                    currentRoute.startsWith('${item.route}/');

                return _RailItemTile(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),

          // Footer with Collapse Toggle & Profile Snippet
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      height: AppConstants.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 16 : 20),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'V',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstants.appName,
                    style: AppTypography.title.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 16,
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final user = currentUser ?? AppUser.devAdmin();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: onToggleCollapse,
            icon: Icon(
              isCollapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: isCollapsed
                ? 'Expand navigation rail'
                : 'Collapse navigation rail',
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
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
              if (!isCollapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.role,
                        style: AppTypography.caption.copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RailItemTile extends StatefulWidget {
  final NavigationItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _RailItemTile({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_RailItemTile> createState() => _RailItemTileState();
}

class _RailItemTileState extends State<_RailItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isActive = widget.isActive;
    final isCollapsed = widget.isCollapsed;

    Color backgroundColor = Colors.transparent;
    if (isActive) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.12);
    } else if (_isHovered) {
      backgroundColor = AppColors.surfaceElevated;
    }

    final Border border = isActive
        ? Border.all(color: AppColors.glassBorderActive)
        : Border.all(color: Colors.transparent);

    final iconColor = isActive
        ? AppColors.primary
        : (_isHovered ? AppColors.textPrimary : AppColors.textSecondary);

    final tile = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppConstants.fastAnimationDuration,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                isActive ? (item.selectedIcon ?? item.icon) : item.icon,
                size: 20,
                color: iconColor,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(message: item.tooltip, preferBelow: false, child: tile);
    }

    return tile;
  }
}

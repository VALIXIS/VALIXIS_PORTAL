import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/dashboard_provider.dart';

/// Quick Action shortcuts for common employee workflows.
class DashboardQuickActions extends ConsumerWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACCESS',
          style: AppTypography.telemetryHeader(
            size: 10,
            color: AppColors.textMuted,
            spacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _QuickActionPill(
              label: 'View My Tasks',
              icon: Icons.task_alt_rounded,
              color: AppColors.brandBlue,
              onTap: () => context.go(AppRoutes.tasks),
            ),
            _QuickActionPill(
              label: 'Profile & Settings',
              icon: Icons.person_outline_rounded,
              color: AppColors.brandPurple,
              onTap: () => context.go(AppRoutes.profile),
            ),
            _QuickActionPill(
              label: 'Sync Data',
              icon: Icons.refresh_rounded,
              color: AppColors.brandCyan,
              onTap: () => ref.invalidate(dashboardProvider),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionPill extends StatefulWidget {
  const _QuickActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuickActionPill> createState() => _QuickActionPillState();
}

class _QuickActionPillState extends State<_QuickActionPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.snappy,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surfaceElevated : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.5)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: widget.color),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                widget.label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: _isHovered ? widget.color : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_durations.dart';

/// Executive Quick Navigation toolbar for manager command operations.
class ManagerQuickActions extends StatelessWidget {
  const ManagerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
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
            _ActionPill(
              label: 'My Tasks',
              icon: Icons.assignment_ind_rounded,
              color: AppColors.brandCyan,
              onTap: () => context.go(AppRoutes.tasks),
            ),
            _ActionPill(
              label: 'All Tasks',
              icon: Icons.assignment_rounded,
              color: AppColors.brandCyan,
              onTap: () => context.go(AppRoutes.managerTasks),
            ),
            _ActionPill(
              label: 'Reviews & PRs',
              icon: Icons.rate_review_rounded,
              color: AppColors.brandBlue,
              onTap: () => context.go(AppRoutes.managerReviews),
            ),
            _ActionPill(
              label: 'Team',
              icon: Icons.people_alt_rounded,
              color: AppColors.success,
              onTap: () => context.go(AppRoutes.managerEmployees),
            ),
            _ActionPill(
              label: 'Audit Logs',
              icon: Icons.fact_check_rounded,
              color: AppColors.brandPurple,
              onTap: () => context.go(AppRoutes.managerAuditLogs),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({
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
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
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


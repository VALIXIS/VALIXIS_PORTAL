import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Executive Quick Actions toolbar for manager operations.
class ManagerQuickActions extends StatelessWidget {
  const ManagerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ActionPill(
              label: 'Create Task',
              icon: Icons.add_rounded,
              color: AppColors.brandCyan,
              onTap: () => context.go(AppRoutes.managerCreateTask),
            ),
            _ActionPill(
              label: 'Assign Task',
              icon: Icons.assignment_ind_rounded,
              color: AppColors.brandBlue,
              onTap: () => context.go(AppRoutes.managerAssignments),
            ),
            _ActionPill(
              label: 'Review Submissions',
              icon: Icons.rate_review_rounded,
              color: AppColors.brandPurple,
              onTap: () => context.go(AppRoutes.managerReviews),
            ),
            _ActionPill(
              label: 'Employee Roster',
              icon: Icons.people_alt_rounded,
              color: AppColors.success,
              onTap: () => context.go(AppRoutes.managerEmployees),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

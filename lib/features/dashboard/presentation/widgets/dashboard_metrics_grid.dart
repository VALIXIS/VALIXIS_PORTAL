import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/glass_card.dart';

/// Grid of metric cards summarizing active task counts and completion rates.
class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({
    super.key,
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;

    return Flex(
      direction: isCompact ? Axis.vertical : Axis.horizontal,
      children: [
        Expanded(
          flex: isCompact ? 0 : 1,
          child: _StatCard(
            title: 'Pending Tasks',
            value: pendingCount.toString(),
            badgeText: 'In Progress',
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
          ),
        ),
        SizedBox(
          width: isCompact ? 0 : AppSpacing.md,
          height: isCompact ? AppSpacing.md : 0,
        ),
        Expanded(
          flex: isCompact ? 0 : 1,
          child: _StatCard(
            title: 'Completed Tasks',
            value: completedCount.toString(),
            badgeText: 'Verified',
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String badgeText;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

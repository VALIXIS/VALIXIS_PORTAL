import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/components/glass_card.dart';

/// Grid of metric cards summarizing active task counts, completion rates, and gamified sprint progress bar.
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
    final total = pendingCount + completedCount;
    final progress = total > 0 ? (completedCount / total) : 0.0;
    final percentage = (progress * 100).round();

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 700;

    return Column(
      children: [
        Flex(
          direction: isCompact ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: isCompact ? 0 : 1,
              child: _StatCard(
                title: 'Pending Tasks',
                value: pendingCount.toString(),
                badgeText: 'Action Needed',
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
                onTap: () => context.go(AppRoutes.tasks),
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
                badgeText: 'Verified & Merged',
                icon: Icons.task_alt_rounded,
                color: AppColors.success,
                onTap: () => context.go(AppRoutes.tasks),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          showGlow: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.brandCyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.brandCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.brandCyan,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Weekly Sprint Velocity',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '$percentage% Sprint Velocity',
                      style: AppTypography.telemetryHeader(
                        size: 10,
                        color: AppColors.brandCyan,
                        spacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage == 100 ? AppColors.success : AppColors.brandCyan,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount of $total assigned tasks completed',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    percentage == 100 ? '🎉 Sprint Goal Achieved!' : '${100 - percentage}% remaining',
                    style: TextStyle(
                      color: percentage == 100 ? AppColors.success : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
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
    required this.onTap,
  });

  final String title;
  final String value;
  final String badgeText;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isInteractive: true,
      showGlow: true,
      onTap: onTap,
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.metricValue(
                  size: 32,
                  weight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

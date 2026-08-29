import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import 'task_badge.dart';

/// Premium interactive task card displaying GitHub repo, deadline countdown, and status.
class TaskCard extends StatefulWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

  Widget _buildUrgencyBadge(DateTime deadline) {
    final now = DateTime.now();
    final diffDays = deadline.difference(now).inDays;

    Color badgeColor;
    String label;

    if (diffDays < 0) {
      badgeColor = AppColors.error;
      label = 'Overdue';
    } else if (diffDays == 0) {
      badgeColor = AppColors.error;
      label = 'Due Today';
    } else if (diffDays <= 2) {
      badgeColor = AppColors.warning;
      label = '$diffDays days left';
    } else {
      badgeColor = AppColors.success;
      label = '$diffDays days left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 11, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final repo = task.githubRepo ?? 'VALIXIS_PORTAL';
    final branch = task.branchName;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/tasks/${task.id}'),
            borderRadius: BorderRadius.circular(20),
            child: GlassCard(
              showGlow: _isHovered,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.code_rounded, size: 13, color: AppColors.brandCyan),
                                const SizedBox(width: 4),
                                Text(
                                  repo,
                                  style: const TextStyle(color: AppColors.brandCyan, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                if (branch != null && branch.isNotEmpty) ...[
                                  const Text(' • ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  Text(
                                    branch,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      PriorityBadge(priority: task.priority),
                    ],
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      task.description!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatShortDate(task.deadline),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildUrgencyBadge(task.deadline),
                        ],
                      ),
                      StatusBadge(status: task.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

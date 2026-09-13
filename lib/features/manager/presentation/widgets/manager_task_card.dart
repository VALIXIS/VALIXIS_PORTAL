import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import 'manager_task_details_sheet.dart';

/// Premium Mobile Task Card for manager monitoring and assignment management.
class ManagerTaskCard extends StatelessWidget {
  const ManagerTaskCard({
    super.key,
    required this.task,
    required this.onReassign,
    required this.onUnassign,
    this.onEdit,
  });

  final Task task;
  final VoidCallback onReassign;
  final VoidCallback onUnassign;
  final VoidCallback? onEdit;

  Color _getStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.assigned => AppColors.telemetryViolet,
      TaskStatus.inProgress => AppColors.brandCyan,
      TaskStatus.submitted => AppColors.telemetryIndigo,
      TaskStatus.approved => AppColors.success,
      TaskStatus.rejected => AppColors.error,
    };
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final isOverdue = deadline.isBefore(now) && !task.status.isCompleted;
    final diff = deadline.difference(now);

    if (isOverdue) {
      final days = now.difference(deadline).inDays;
      return days == 0 ? 'Overdue today' : 'Overdue by ${days}d';
    } else {
      final days = diff.inDays;
      if (days == 0) return 'Due today';
      if (days == 1) return 'Due tomorrow';
      return 'Due in ${days}d (${DateFormatter.formatShortDate(deadline)})';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = task.priority.color;
    final statusColor = _getStatusColor(task.status);
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !task.status.isCompleted;
    final isAssigned = task.assignedTo.isNotEmpty && task.assignedTo != 'Unassigned';

    return GlassCard(
      isInteractive: true,
      showGlow: isOverdue || task.status == TaskStatus.submitted,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => ManagerTaskDetailsSheet.show(context, task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Priority, Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: priorityColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: priorityColor.withValues(alpha: 0.35), width: 0.8),
                        ),
                        child: Text(
                          task.priority.name.toUpperCase(),
                          style: AppTypography.telemetryHeader(
                            size: 9,
                            color: priorityColor,
                            spacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1),
                    ),
                    child: Text(
                      task.status.label.toUpperCase(),
                      style: AppTypography.telemetryHeader(
                        size: 9,
                        color: statusColor,
                        spacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Title
              Text(
                task.title,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Repo & Branch & PR
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.source_rounded, size: 11, color: AppColors.brandBlue),
                        const SizedBox(width: 4),
                        Text(
                          task.githubRepo ?? 'VALIXIS_PORTAL',
                          style: AppTypography.mono(
                            size: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.branchName != null && task.branchName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fork_right_rounded, size: 11, color: AppColors.brandPurple),
                          const SizedBox(width: 4),
                          Text(
                            task.branchName!,
                            style: AppTypography.mono(
                              size: 10,
                              color: AppColors.brandPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (task.prUrl != null && task.prUrl!.isNotEmpty)
                    InkWell(
                      onTap: () {
                        final uri = Uri.tryParse(task.prUrl!);
                        if (uri != null) launchUrl(uri);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_new_rounded, size: 10, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'PR ACTIVE',
                              style: AppTypography.telemetryHeader(
                                size: 9,
                                color: AppColors.success,
                                spacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.sm),

              // Footer: Assignee, Deadline & Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: isAssigned ? AppColors.primaryGradient : null,
                            color: isAssigned ? null : AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 13,
                              color: isAssigned ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAssigned ? task.assignedTo : 'Unassigned',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: isAssigned ? AppColors.textPrimary : AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.alarm_rounded,
                                    size: 11,
                                    color: isOverdue ? AppColors.error : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      _formatDeadline(task.deadline),
                                      style: AppTypography.mono(
                                        size: 10,
                                        color: isOverdue ? AppColors.error : AppColors.textMuted,
                                        weight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandCyan),
                          tooltip: 'Edit Task',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: onEdit,
                        ),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.brandCyan),
                        tooltip: 'Assign / Reassign',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: onReassign,
                      ),
                      if (isAssigned)
                        IconButton(
                          icon: const Icon(Icons.person_remove_rounded, size: 18, color: AppColors.warning),
                          tooltip: 'Unassign',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: onUnassign,
                        ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


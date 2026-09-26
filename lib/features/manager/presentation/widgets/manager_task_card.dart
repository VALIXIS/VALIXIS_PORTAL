import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import '../../../tasks/domain/models/sprint_models.dart';
import '../../../tasks/presentation/widgets/task_detail_drawer.dart';
import '../../../tasks/presentation/widgets/task_prompt_helper.dart';

/// Premium Mobile & Desktop Task Card for manager monitoring with multi-app sprint filters and prompt copying.
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

  void _copyBranch(BuildContext context, String branch) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: branch));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.brandPurple),
        ),
        content: Text(
          'Branch "$branch" copied',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sprintApp = SprintApp.fromTask(task);
    final sprintDay = SprintDay.fromTask(task);
    final stage = SprintWorkflowStage.fromTask(task);
    final priorityColor = task.priority.color;
    final statusColor = _getStatusColor(task.status);
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !task.status.isCompleted;
    final isAssigned = task.assignedTo.isNotEmpty && task.assignedTo != 'Unassigned';

    return GlassCard(
      isInteractive: true,
      showGlow: isOverdue || task.status == TaskStatus.submitted,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => TaskDetailDrawer.show(context, task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: App Badge + Sprint Day + Priority + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: sprintApp.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: sprintApp.color.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sprintApp.icon, size: 11, color: sprintApp.color),
                            const SizedBox(width: 4),
                            Text(
                              sprintApp.displayName,
                              style: TextStyle(
                                color: sprintApp.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Sprint Day
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          sprintDay.shortLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Priority Pill
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

              // Repo & Branch & PR & Workflow Stage
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
                    InkWell(
                      onTap: () => _copyBranch(context, task.branchName!),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.4)),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stage.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: stage.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(stage.icon, size: 10, color: stage.color),
                        const SizedBox(width: 3),
                        Text(
                          stage.label.toUpperCase(),
                          style: TextStyle(
                            color: stage.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.sm),

              // Footer: Assignee, Deadline, Glowing Copy AG Prompt & Quick Actions
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
                      // One-Click Glowing Copy AG Prompt Button
                      InkWell(
                        onTap: () => TaskPromptHelper.copyAgPrompt(
                          context,
                          task.aiPrompt,
                          taskTitle: task.title,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.brandCyan.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandCyan.withValues(alpha: 0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt_rounded, size: 13, color: AppColors.brandCyan),
                              SizedBox(width: 3),
                              Text(
                                'AG Prompt',
                                style: TextStyle(
                                  color: AppColors.brandCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.brandCyan),
                          tooltip: 'Edit Task',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                          onPressed: onEdit,
                        ),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.brandCyan),
                        tooltip: 'Assign / Reassign',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        onPressed: onReassign,
                      ),
                      if (isAssigned)
                        IconButton(
                          icon: const Icon(Icons.person_remove_rounded, size: 18, color: AppColors.warning),
                          tooltip: 'Unassign',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                          onPressed: onUnassign,
                        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/operations_provider.dart';

/// Card component rendering individual task details, priority tag,
/// assignee badge, and status transition quick-action.
class TaskCard extends ConsumerWidget {
  final TaskItem task;
  final ValueChanged<String>? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Priority tag + Status Move Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriorityBadge(),
              _buildStatusMenu(context, ref),
            ],
          ),
          const SizedBox(height: 8),

          // Task Title
          Text(
            task.title,
            style: AppTypography.title.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Task Description (if present)
          if (task.description != null && task.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),

          // Footer: Project Tag & Assignee + Due Date
          Row(
            children: [
              // Project Tag
              if (task.projectName != null && task.projectName!.isNotEmpty) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.folder_outlined,
                          size: 11,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            task.projectName!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                const Spacer(),

              // Assignee Avatar / Badge
              Tooltip(
                message: task.assigneeName != null
                    ? 'Assigned to ${task.assigneeName}'
                    : 'Unassigned',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: task.assignedTo != null
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.surfaceElevated,
                      child: Text(
                        task.assigneeInitials,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: task.assignedTo != null
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (task.assigneeName != null) ...[
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text(
                          task.assigneeName!,
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Due Date (if any)
              if (task.dueDate != null) ...[
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded, size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      '${task.dueDate!.month}/${task.dueDate!.day}',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final color = task.priorityColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            task.priorityDisplayName,
            style: AppTypography.label.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: 'Change Status',
      icon: const Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.textSecondary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 140),
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      onSelected: (newStatus) {
        if (newStatus != task.status) {
          if (onStatusChanged != null) {
            onStatusChanged!(newStatus);
          } else {
            ref.read(tasksProvider.notifier).updateTaskStatus(
                  taskId: task.id,
                  status: newStatus,
                );
          }
        }
      },
      itemBuilder: (context) => [
        _buildPopupItem('backlog', 'Backlog', Icons.inbox_outlined),
        _buildPopupItem('in_progress', 'In Progress', Icons.sync_rounded),
        _buildPopupItem('under_review', 'Under Review', Icons.rate_review_outlined),
        _buildPopupItem('done', 'Done', Icons.check_circle_outline_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String statusVal, String label, IconData icon) {
    final isCurrent = task.status == statusVal;
    return PopupMenuItem<String>(
      value: statusVal,
      height: 34,
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (isCurrent)
            const Icon(Icons.check_rounded, size: 12, color: AppColors.primary),
        ],
      ),
    );
  }
}

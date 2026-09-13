import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import 'manager_task_details_sheet.dart';

/// Next-Gen Data table for Manager Tasks displaying specifications, telemetry status, and quick action controls.
class ManagerTasksTable extends StatelessWidget {
  const ManagerTasksTable({
    super.key,
    required this.tasks,
    required this.onReassign,
    required this.onUnassign,
    required this.onDelete,
    required this.onEdit,
    this.sortField = 'deadline',
    this.sortAscending = true,
    this.onSort,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onReassign;
  final ValueChanged<Task> onUnassign;
  final ValueChanged<Task> onDelete;
  final ValueChanged<Task> onEdit;
  final String sortField;
  final bool sortAscending;
  final void Function(String field, bool ascending)? onSort;

  Widget _buildHeaderLabel(String title, String fieldKey) {
    final isSelected = sortField == fieldKey;
    final iconData = isSelected
        ? (sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
        : Icons.unfold_more_rounded;
    final iconColor = isSelected ? AppColors.brandCyan : AppColors.textMuted;
    final textColor = isSelected ? AppColors.brandCyan : AppColors.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isSelected) {
            onSort?.call(fieldKey, !sortAscending);
          } else {
            onSort?.call(fieldKey, true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTypography.telemetryHeader(
                  size: 10,
                  color: textColor,
                  spacing: 0.8,
                ),
              ),
              const SizedBox(width: 4),
              Icon(iconData, size: 13, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: 20,
                  horizontalMargin: 20,
                  headingRowHeight: 46,
                  dataRowMaxHeight: 58,
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
                  columns: [
                    DataColumn(label: _buildHeaderLabel('Task Title', 'title')),
                    DataColumn(label: _buildHeaderLabel('Repository', 'repo')),
                    DataColumn(label: _buildHeaderLabel('Priority', 'priority')),
                    DataColumn(label: _buildHeaderLabel('Status', 'assignment')),
                    DataColumn(label: _buildHeaderLabel('Deadline', 'deadline')),
                    DataColumn(label: _buildHeaderLabel('PR Link', 'pr')),
                    DataColumn(
                      label: Text(
                        'ACTIONS',
                        style: AppTypography.telemetryHeader(
                          size: 10,
                          color: AppColors.textMuted,
                          spacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                  rows: tasks.map((task) {
                    final hasPr = task.prUrl != null && task.prUrl!.isNotEmpty;
                    final isAssigned = task.assignedTo.isNotEmpty && task.assignedTo != 'Unassigned';

                    return DataRow(
                      cells: [
                        // Task Title & Branch
                        DataCell(
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: () => ManagerTaskDetailsSheet.show(context, task),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      task.title,
                                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.fork_right_rounded,
                                          size: 11,
                                          color: AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          task.branchName ?? 'main',
                                          style: AppTypography.mono(
                                            size: 10,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Repository
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.source_rounded,
                                  size: 11,
                                  color: AppColors.brandBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.githubRepo ?? 'VALIXIS_PORTAL',
                                  style: AppTypography.mono(
                                    size: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Priority
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: task.priority.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: task.priority.color.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              task.priority.label.toUpperCase(),
                              style: AppTypography.telemetryHeader(
                                size: 9,
                                color: task.priority.color,
                                spacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        // Assignment Status
                        DataCell(
                          isAssigned
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.telemetryViolet.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.telemetryViolet.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: AppColors.telemetryViolet,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'ASSIGNED',
                                        style: AppTypography.telemetryHeader(
                                          size: 9,
                                          color: AppColors.telemetryViolet,
                                          spacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    'UNASSIGNED',
                                    style: AppTypography.telemetryHeader(
                                      size: 9,
                                      color: AppColors.textMuted,
                                      spacing: 0.5,
                                    ),
                                  ),
                                ),
                        ),

                        // Deadline
                        DataCell(
                          Text(
                            DateFormatter.formatShortDate(task.deadline),
                            style: AppTypography.mono(
                              size: 11,
                              color: task.deadline.isBefore(DateTime.now()) && !task.status.isCompleted
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // PR Link
                        DataCell(
                          hasPr
                              ? InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(task.prUrl!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.success.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.open_in_new_rounded,
                                          size: 11,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'OPEN PR',
                                          style: AppTypography.telemetryHeader(
                                            size: 9,
                                            color: AppColors.success,
                                            spacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Text(
                                  '—',
                                  style: AppTypography.mono(
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                        ),

                        // Quick Actions
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.brandCyan),
                                tooltip: 'View Telemetry',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                onPressed: () => ManagerTaskDetailsSheet.show(context, task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.brandCyan),
                                tooltip: 'Edit Task',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                onPressed: () => onEdit(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.person_add_outlined, size: 16, color: AppColors.telemetryViolet),
                                tooltip: 'Reassign Engineer',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                onPressed: () => onReassign(task),
                              ),
                              if (isAssigned)
                                IconButton(
                                  icon: const Icon(Icons.person_remove_outlined, size: 16, color: AppColors.warning),
                                  tooltip: 'Unassign Task',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  onPressed: () => onUnassign(task),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                tooltip: 'Delete Task',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                onPressed: () => onDelete(task),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


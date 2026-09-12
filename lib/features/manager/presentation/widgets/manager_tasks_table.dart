import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import 'manager_task_details_sheet.dart';

/// Data table for Manager Tasks displaying task specifications, assigned employee, status, and custom interactive column header sorting.
class ManagerTasksTable extends StatelessWidget {
  const ManagerTasksTable({
    super.key,
    required this.tasks,
    required this.onReassign,
    required this.onUnassign,
    required this.onDelete,
    this.sortField = 'deadline',
    this.sortAscending = true,
    this.onSort,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onReassign;
  final ValueChanged<Task> onUnassign;
  final ValueChanged<Task> onDelete;
  final String sortField;
  final bool sortAscending;
  final void Function(String field, bool ascending)? onSort;

  /// Helper to filter out raw UUID strings from assignee display
  String? _getCleanAssigneeName(String assignee) {
    if (assignee.isEmpty || assignee == 'Unassigned') return null;
    final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(assignee) ||
                   RegExp(r'^[0-9a-fA-F-]{20,}$').hasMatch(assignee);
    if (isUuid) return null;
    return assignee;
  }

  Widget _buildHeaderLabel(String title, String fieldKey) {
    final isSelected = sortField == fieldKey;
    final iconData = isSelected
        ? (sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
        : Icons.unfold_more_rounded;
    final iconColor = isSelected ? AppColors.brandCyan : AppColors.textMuted.withAlpha(140);
    final textColor = isSelected ? AppColors.brandCyan : AppColors.textPrimary;

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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(iconData, size: 14, color: iconColor),
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
                  columnSpacing: 18,
                  horizontalMargin: 16,
                  headingRowHeight: 48,
                  dataRowMaxHeight: 56,
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
                  columns: [
                    DataColumn(label: _buildHeaderLabel('Task Title', 'title')),
                    DataColumn(label: _buildHeaderLabel('Repository', 'repo')),
                    DataColumn(label: _buildHeaderLabel('Priority', 'priority')),
                    DataColumn(label: _buildHeaderLabel('Assignment', 'assignment')),
                    DataColumn(label: _buildHeaderLabel('Deadline', 'deadline')),
                    DataColumn(label: _buildHeaderLabel('PR Submitted', 'pr')),
                    const DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  rows: tasks.map((task) {
                    final hasPr = task.prUrl != null && task.prUrl!.isNotEmpty;
                    final isAssigned = task.assignedTo.isNotEmpty && task.assignedTo != 'Unassigned';
                    final cleanName = _getCleanAssigneeName(task.assignedTo);

                    return DataRow(
                      cells: [
                        DataCell(
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: () => ManagerTaskDetailsSheet.show(context, task),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      color: AppColors.brandCyan,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    task.branchName ?? 'main',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            task.githubRepo ?? 'VALIXIS_PORTAL',
                            style: const TextStyle(
                              color: AppColors.brandBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            task.priority.label,
                            style: TextStyle(
                              color: task.priority.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataCell(
                          isAssigned
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandPurple.withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.brandPurple.withAlpha(80)),
                                      ),
                                      child: const Text(
                                        'Assigned',
                                        style: TextStyle(color: AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if (cleanName != null) ...[
                                      const SizedBox(width: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 160),
                                        child: Text(
                                          cleanName,
                                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.textMuted.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.textMuted.withAlpha(80)),
                                  ),
                                  child: const Text(
                                    'Unassigned',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ),
                        ),
                        DataCell(
                          Text(
                            DateFormatter.formatShortDate(task.deadline),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
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
                                      color: AppColors.success.withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.success.withAlpha(90)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.success),
                                        SizedBox(width: 4),
                                        Text('Yes', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.textMuted.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('No', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.brandCyan),
                                tooltip: 'Task Details',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () => ManagerTaskDetailsSheet.show(context, task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.person_add_outlined, size: 18, color: AppColors.brandPurple),
                                tooltip: 'Reassign',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () => onReassign(task),
                              ),
                              if (isAssigned)
                                IconButton(
                                  icon: const Icon(Icons.person_remove_outlined, size: 18, color: AppColors.warning),
                                  tooltip: 'Unassign',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () => onUnassign(task),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                tooltip: 'Delete Task',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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

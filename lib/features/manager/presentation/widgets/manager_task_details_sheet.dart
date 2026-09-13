import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/models/task.dart';
import '../providers/manager_dashboard_provider.dart';
import 'manager_task_dialogs.dart';

/// Modal bottom sheet displaying comprehensive task specification and live assignment controls.
class ManagerTaskDetailsSheet extends ConsumerWidget {
  const ManagerTaskDetailsSheet({super.key, required this.task});

  final Task task;

  static Future<void> show(BuildContext context, Task task) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ManagerTaskDetailsSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAssigned = task.assignedTo.isNotEmpty && task.assignedTo != 'Unassigned';
    final metricsAsync = ref.watch(managerDashboardProvider);
    final allEmployees = metricsAsync.valueOrNull?.allEmployees ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'TASK DETAILS',
                          style: const TextStyle(
                            color: AppColors.brandCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priority.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.brandPurple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Assignment & Status row
                  _DetailRow(
                    label: 'Status',
                    value: task.status.label.toUpperCase(),
                    valueColor: AppColors.brandCyan,
                  ),
                  _DetailRow(
                    label: 'Assigned To',
                    value: isAssigned ? task.assignedTo : 'Unassigned',
                    valueColor: isAssigned ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                  _DetailRow(
                    label: 'Repository',
                    value: task.githubRepo ?? 'VALIXIS_PORTAL',
                    valueColor: AppColors.brandBlue,
                  ),
                  if (task.branchName != null && task.branchName!.isNotEmpty)
                    _DetailRow(
                      label: 'Branch Name',
                      value: task.branchName!,
                      valueColor: AppColors.brandPurple,
                    ),
                  _DetailRow(
                    label: 'Deadline',
                    value: DateFormatter.formatShortDate(task.deadline),
                    valueColor: task.deadline.isBefore(DateTime.now()) && !task.status.isCompleted
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  if (task.prUrl != null && task.prUrl!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: () {
                        final uri = Uri.tryParse(task.prUrl!);
                        if (uri != null) launchUrl(uri);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.brandCyan.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.brandCyan.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link_rounded, color: AppColors.brandCyan, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pull Request Submitted',
                                    style: TextStyle(
                                      color: AppColors.brandCyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    task.prUrl!,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded, color: AppColors.brandCyan, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        task.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (task.objective != null && task.objective!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Engineering Objective',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        task.objective!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (task.aiPrompt != null && task.aiPrompt!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'AI Prompt Specification',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        task.aiPrompt!,
                        style: AppTypography.mono(
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl2),
                  // Actions Row (Edit, Assign/Reassign, Unassign)
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Edit Task',
                          variant: AppButtonVariant.secondary,
                          prefixIcon: Icons.edit_outlined,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final ok = await ManagerTaskDialogs.showEditTaskDialog(
                              context: context,
                              task: task,
                              managerRepo: ref.read(managerRepositoryProvider),
                            );
                            if (ok == true) {
                              ref.invalidate(managerDashboardProvider);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: isAssigned ? 'Reassign' : 'Assign',
                          prefixIcon: Icons.person_add_alt_1_rounded,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await ManagerTaskDialogs.showReassignDialog(
                              context: context,
                              task: task,
                              employees: allEmployees,
                              managerRepo: ref.read(managerRepositoryProvider),
                            );
                            ref.invalidate(managerDashboardProvider);
                          },
                        ),
                      ),
                      if (isAssigned) ...[
                        const SizedBox(width: AppSpacing.md),
                        AppButton(
                          label: 'Unassign',
                          variant: AppButtonVariant.danger,
                          prefixIcon: Icons.person_remove_rounded,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await ManagerTaskDialogs.showUnassignDialog(
                              context: context,
                              task: task,
                              managerRepo: ref.read(managerRepositoryProvider),
                            );
                            ref.invalidate(managerDashboardProvider);
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

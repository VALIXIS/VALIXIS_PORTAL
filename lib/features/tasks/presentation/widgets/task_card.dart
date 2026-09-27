import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/glass_card.dart';
import '../../../../shared/models/task.dart';
import '../../domain/models/sprint_models.dart';
import 'task_badge.dart';
import 'task_detail_drawer.dart';
import 'task_prompt_helper.dart';

/// Interactive task card displaying multi-app sprint badge, day tag, PR status, and glowing 1-click prompt action.
class TaskCard extends StatefulWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

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
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
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
    final sprintApp = SprintApp.fromTask(task);
    final stage = SprintWorkflowStage.fromTask(task);
    final branch = task.branchName;
    final hasPr = task.prUrl != null && task.prUrl!.isNotEmpty;

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
            onTap: () => TaskDetailDrawer.show(context, task),
            borderRadius: BorderRadius.circular(16),
            child: GlassCard(
              showGlow: _isHovered,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: App Badge + Sprint Day + Priority + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: sprintApp.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: sprintApp.color.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sprintApp.icon, size: 12, color: sprintApp.color),
                            const SizedBox(width: 4),
                            Text(
                              sprintApp.displayName,
                              style: TextStyle(
                                color: sprintApp.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Priority & Status
                      PriorityBadge(priority: task.priority),
                      const SizedBox(width: 6),
                      StatusBadge(status: task.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Task Title
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Metadata Chips: Repo, Branch, PR, Stage
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Repo
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
                            const Icon(Icons.code_rounded, size: 12, color: AppColors.brandCyan),
                            const SizedBox(width: 4),
                            Text(
                              task.githubRepo ?? 'VALIXIS_PORTAL',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Branch with click-to-copy
                      if (branch != null && branch.isNotEmpty)
                        InkWell(
                          onTap: () => _copyBranch(context, branch),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandPurple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fork_right_rounded, size: 12, color: AppColors.brandPurple),
                                const SizedBox(width: 4),
                                Text(
                                  branch,
                                  style: const TextStyle(
                                    color: AppColors.brandPurple,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded, size: 10, color: AppColors.brandPurple),
                              ],
                            ),
                          ),
                        ),

                      // PR Status
                      if (hasPr)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.commit_rounded, size: 11, color: AppColors.success),
                              SizedBox(width: 3),
                              Text(
                                'PR ACTIVE',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Workflow Stage
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
                            Icon(stage.icon, size: 11, color: stage.color),
                            const SizedBox(width: 4),
                            Text(
                              stage.label.toUpperCase(),
                              style: TextStyle(
                                color: stage.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      task.description!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  const SizedBox(height: AppSpacing.sm),

                  // Bottom Action Row: Deadline & High-Visibility Glowing Copy AG Prompt Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Deadline info
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
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildUrgencyBadge(task.deadline),
                        ],
                      ),

                      // Action Buttons: Copy AG Prompt + Open Drawer
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing One-Click Copy AG Prompt Button
                          InkWell(
                            onTap: () => TaskPromptHelper.copyAgPrompt(
                              context,
                              task.aiPrompt,
                              taskTitle: task.title,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.brandCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.brandCyan.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandCyan.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.bolt_rounded, size: 14, color: AppColors.brandCyan),
                                  SizedBox(width: 4),
                                  Text(
                                    'Copy AG Prompt',
                                    style: TextStyle(
                                      color: AppColors.brandCyan,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: _isHovered ? AppColors.brandCyan : AppColors.textMuted,
                          ),
                        ],
                      ),
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

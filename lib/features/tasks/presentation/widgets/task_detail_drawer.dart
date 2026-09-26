import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/components/app_button.dart';
import '../../../../shared/models/task.dart';
import '../../domain/models/sprint_models.dart';
import 'task_badge.dart';
import 'task_prompt_helper.dart';

/// Interactive slide-over drawer on Desktop or bottom modal sheet on Mobile for complete task specification.
class TaskDetailDrawer extends StatelessWidget {
  const TaskDetailDrawer({
    super.key,
    required this.task,
    this.scrollController,
  });

  final Task task;
  final ScrollController? scrollController;

  /// Shows the drawer as a right slide-over modal on Desktop Web ($\ge 800$px) or as a bottom sheet on Mobile.
  static Future<void> show(BuildContext context, Task task) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 800) {
      return showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Task Details',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
        transitionBuilder: (context, anim1, anim2, child) {
          final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: (width * 0.55).clamp(520.0, 720.0),
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(-8, 0),
                      ),
                    ],
                    border: const Border(
                      left: BorderSide(color: AppColors.glassBorder, width: 1.2),
                    ),
                  ),
                  child: TaskDetailDrawer(task: task),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => TaskDetailDrawer(
            task: task,
            scrollController: scrollController,
          ),
        ),
      );
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
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.brandPurple),
        ),
        content: Text(
          'Branch "$branch" copied to clipboard',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sprintApp = SprintApp.fromTask(task);
    final sprintDay = SprintDay.fromTask(task);
    final workflowStage = SprintWorkflowStage.fromTask(task);
    final assignee = task.assignedTo.isNotEmpty ? task.assignedTo : 'Unassigned';
    final hasPrompt = task.aiPrompt != null && task.aiPrompt!.trim().isNotEmpty;

    return Column(
      children: [
        // Drawer Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              // App Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sprintApp.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sprintApp.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sprintApp.icon, size: 14, color: sprintApp.color),
                    const SizedBox(width: 6),
                    Text(
                      sprintApp.displayName.toUpperCase(),
                      style: AppTypography.telemetryHeader(
                        size: 10,
                        color: sprintApp.color,
                        spacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Sprint Day
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  sprintDay.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),

              // Priority & Status
              PriorityBadge(priority: task.priority),
              const SizedBox(width: 6),
              StatusBadge(status: task.status),
              const SizedBox(width: 8),

              // Close
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // Body content
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.xl),
            physics: const BouncingScrollPhysics(),
            children: [
              // Task Title
              Text(
                task.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Assignee & Deadline Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          assignee.isNotEmpty ? assignee[0].toUpperCase() : 'E',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignee,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sprint Assignee • ${sprintDay.label}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TARGET DEADLINE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatShortDate(task.deadline),
                          style: const TextStyle(
                            color: AppColors.brandCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 5-Stage Sprint Progress Bar
              _buildWorkflowTimeline(workflowStage),
              const SizedBox(height: AppSpacing.xl),

              // Objective & Requirements
              if (task.objective != null && task.objective!.trim().isNotEmpty) ...[
                _buildSectionTitle('Sprint Objective & Requirements', Icons.flag_rounded, AppColors.brandCyan),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    task.objective!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Description / Technical Specs
              if (task.description != null && task.description!.trim().isNotEmpty) ...[
                _buildSectionTitle('Technical Specifications', Icons.description_outlined, AppColors.brandBlue),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
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
                const SizedBox(height: AppSpacing.lg),
              ],

              // Repository & Branch Target
              _buildSectionTitle('Repository & Feature Branch', Icons.source_rounded, AppColors.brandPurple),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.brandCyan),
                        const SizedBox(width: 8),
                        const Text('Repo:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.githubRepo ?? 'VALIXIS_PORTAL',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task.branchName != null && task.branchName!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.divider, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.fork_right_rounded, size: 16, color: AppColors.brandPurple),
                          const SizedBox(width: 8),
                          const Text('Branch:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.branchName!,
                              style: const TextStyle(
                                color: AppColors.brandPurple,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _copyBranch(context, task.branchName!),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.copy_rounded, size: 12, color: AppColors.brandPurple),
                                  SizedBox(width: 4),
                                  Text(
                                    'Copy Branch',
                                    style: TextStyle(
                                      color: AppColors.brandPurple,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Syntax-Highlighted / Dark Code Container for AI Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Antigravity AI Prompt', Icons.auto_awesome_rounded, AppColors.brandCyan),
                  InkWell(
                    onTap: () => TaskPromptHelper.copyAgPrompt(context, task.aiPrompt, taskTitle: task.title),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandCyan.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bolt_rounded, size: 14, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            'Copy AG Prompt',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBaseDeep,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandCyan.withValues(alpha: 0.05),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.terminal_rounded, size: 14, color: AppColors.brandCyan),
                        SizedBox(width: 6),
                        Text(
                          'ANTIGRAVITY_PROMPT.MD',
                          style: TextStyle(
                            color: AppColors.brandCyan,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 10),
                    SelectableText(
                      hasPrompt ? task.aiPrompt! : '// No AI Prompt specified for this assignment.',
                      style: TextStyle(
                        color: hasPrompt ? AppColors.textPrimary : AppColors.textMuted,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Copy Full Prompt for Antigravity',
                        prefixIcon: Icons.bolt_rounded,
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.medium,
                        onPressed: () => TaskPromptHelper.copyAgPrompt(context, task.aiPrompt, taskTitle: task.title),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Pull Request Link Section
              _buildSectionTitle('Pull Request & Integration', Icons.call_merge_rounded, AppColors.success),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (task.prUrl != null && task.prUrl!.isNotEmpty)
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (task.prUrl != null && task.prUrl!.isNotEmpty)
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.commit_rounded,
                        size: 20,
                        color: (task.prUrl != null && task.prUrl!.isNotEmpty)
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (task.prUrl != null && task.prUrl!.isNotEmpty)
                                ? 'Pull Request Active'
                                : 'No Pull Request Submitted Yet',
                            style: TextStyle(
                              color: (task.prUrl != null && task.prUrl!.isNotEmpty)
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (task.prUrl != null && task.prUrl!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.prUrl!,
                              style: const TextStyle(
                                color: AppColors.brandCyan,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (task.prUrl != null && task.prUrl!.isNotEmpty)
                      AppButton(
                        label: 'Open PR',
                        prefixIcon: Icons.open_in_new_rounded,
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.small,
                        onPressed: () {
                          final uri = Uri.tryParse(task.prUrl!);
                          if (uri != null) launchUrl(uri);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkflowTimeline(SprintWorkflowStage currentStage) {
    final stages = SprintWorkflowStage.values;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SPRINT IMPLEMENTATION LIFECYCLE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: currentStage.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: currentStage.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  currentStage.label.toUpperCase(),
                  style: TextStyle(
                    color: currentStage.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (int i = 0; i < stages.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= currentStage.stageIndex
                              ? currentStage.color
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stages[i].label,
                        style: TextStyle(
                          color: i <= currentStage.stageIndex
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: i == currentStage.stageIndex ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (i < stages.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

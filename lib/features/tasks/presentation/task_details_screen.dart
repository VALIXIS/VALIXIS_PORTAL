import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/layout/responsive_layout.dart';
import '../../../shared/models/task.dart';
import 'providers/task_details_provider.dart';
import 'widgets/ai_prompt_card.dart';
import 'widgets/pr_submission_card.dart';
import 'widgets/task_attachments_card.dart';
import 'widgets/task_badge.dart';
import 'widgets/task_comments_section.dart';
import 'widgets/task_details_shimmer.dart';
import 'widgets/task_history_timeline.dart';
import 'widgets/task_info_section.dart';

/// Screen displaying comprehensive details and PR submission for a single task.
class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailsProvider(taskId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Task #$taskId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.tasks),
        ),
      ),
      body: taskAsync.when(
        loading: () => const TaskDetailsShimmer(),
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load task',
            description: err.toString(),
            action: ElevatedButton(
              onPressed: () => ref.refresh(taskDetailsProvider(taskId)),
              child: const Text('Retry'),
            ),
          ),
        ),
        data: (task) {
          if (task == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Task Not Found',
              description: 'No task assignment was found with ID #$taskId',
              action: ElevatedButton(
                onPressed: () => context.go(AppRoutes.tasks),
                child: const Text('Back to Tasks'),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ResponsiveLayout(
              mobile: (context) => _MobileTaskDetailsLayout(task: task),
              desktop: (context) => _DesktopTaskDetailsLayout(task: task),
            ),
          );
        },
      ),
    );
  }
}

class _StatusMetaCard extends StatelessWidget {
  const _StatusMetaCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      showGlow: true,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              StatusBadge(status: task.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Priority',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              PriorityBadge(priority: task.priority),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Deadline',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: 14, color: AppColors.brandCyan),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatShortDate(task.deadline),
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileTaskDetailsLayout extends StatelessWidget {
  const _MobileTaskDetailsLayout({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusMetaCard(task: task),
        const SizedBox(height: AppSpacing.base),
        TaskInfoSection(task: task),
        if (task.aiPrompt != null && task.aiPrompt!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.base),
          AiPromptCard(prompt: task.aiPrompt!),
        ],
        const SizedBox(height: AppSpacing.base),
        PrSubmissionCard(task: task),
        const SizedBox(height: AppSpacing.base),
        const TaskAttachmentsCard(),
        const SizedBox(height: AppSpacing.base),
        TaskCommentsSection(taskId: task.id),
        const SizedBox(height: AppSpacing.base),
        TaskHistoryTimeline(task: task),
      ],
    );
  }
}

class _DesktopTaskDetailsLayout extends StatelessWidget {
  const _DesktopTaskDetailsLayout({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskInfoSection(task: task),
              if (task.aiPrompt != null && task.aiPrompt!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.base),
                AiPromptCard(prompt: task.aiPrompt!),
              ],
              const SizedBox(height: AppSpacing.base),
              TaskCommentsSection(taskId: task.id),
              const SizedBox(height: AppSpacing.base),
              TaskHistoryTimeline(task: task),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _StatusMetaCard(task: task),
              const SizedBox(height: AppSpacing.base),
              PrSubmissionCard(task: task),
              const SizedBox(height: AppSpacing.base),
              const TaskAttachmentsCard(),
            ],
          ),
        ),
      ],
    );
  }
}

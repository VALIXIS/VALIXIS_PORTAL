import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/empty_state.dart';
import '../../../../shared/models/task.dart';
import '../../../tasks/presentation/widgets/task_card.dart';

/// Recent tasks list with staggered entrance animation.
class DashboardRecentTasks extends StatelessWidget {
  const DashboardRecentTasks({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Tasks',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tasks.length}',
                style: const TextStyle(
                  color: AppColors.brandCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (tasks.isEmpty)
          const EmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No active tasks',
            description: 'You have no assigned tasks at the moment.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 350 + (index * 80)),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 16),
                      child: child,
                    ),
                  );
                },
                child: TaskCard(task: task),
              );
            },
          ),
      ],
    );
  }
}

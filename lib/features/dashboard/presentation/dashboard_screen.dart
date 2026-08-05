import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_section_title.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/models/task.dart';
import '../../tasks/presentation/widgets/task_card.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/dashboard_shimmer.dart';

/// Dashboard screen rendering employee greeting, metric cards, and recent tasks.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: dashboardAsync.when(
        loading: () => const DashboardShimmer(),
        error: (err, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load Dashboard',
            description: err.toString(),
            action: AppButton(
              label: 'Retry Loading',
              prefixIcon: Icons.refresh_rounded,
              onPressed: () => ref.refresh(dashboardProvider),
            ),
          ),
        ),
        data: (data) {
          final employee = data.employee;
          final recentTasks = data.recentTasks;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AppSectionTitle(
                      title: 'Welcome, ${employee.fullName}',
                      subtitle: 'Here is your enterprise activity overview',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _MetricCardsRow(
                      pendingCount: data.pendingCount,
                      completedCount: data.completedCount,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const AppSectionTitle(
                      title: 'My Recent Tasks',
                      subtitle: 'Active assignments assigned to you',
                    ),
                    const SizedBox(height: AppSpacing.base),
                    if (recentTasks.isEmpty)
                      const EmptyState(
                        icon: Icons.task_alt_outlined,
                        title: 'No tasks assigned',
                        description:
                            'You currently have no active task assignments.',
                      )
                    else
                      _AnimatedTaskList(tasks: recentTasks),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCardsRow extends StatelessWidget {
  const _MetricCardsRow({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Pending Tasks',
            value: pendingCount.toString(),
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: _StatCard(
            label: 'Completed Tasks',
            value: completedCount.toString(),
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(76)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.base),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedTaskList extends StatelessWidget {
  const _AnimatedTaskList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.base),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: TaskCard(task: task),
        );
      },
    );
  }
}

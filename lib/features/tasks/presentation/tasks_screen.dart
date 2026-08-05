import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_section_title.dart';
import '../../../shared/components/app_shimmer.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/layout/responsive_layout.dart';
import '../../../shared/models/task.dart';
import 'providers/tasks_provider.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_bar.dart';

/// My Tasks screen displaying search, sort, shimmer, and list animations.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _searchQuery = '';
  TaskSortOption _sortOption = TaskSortOption.deadline;

  List<Task> _filterAndSort(List<Task> rawTasks) {
    var filtered = rawTasks.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false);
    }).toList();

    filtered.sort((a, b) {
      return switch (_sortOption) {
        TaskSortOption.deadline => a.deadline.compareTo(b.deadline),
        TaskSortOption.priority =>
          b.priority.index.compareTo(a.priority.index),
        TaskSortOption.status => a.status.index.compareTo(b.status.index),
      };
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionTitle(
              title: 'My Tasks',
              subtitle: 'Task assignments allocated to your profile',
            ),
            const SizedBox(height: AppSpacing.lg),
            TaskFilterBar(
              searchQuery: _searchQuery,
              selectedSort: _sortOption,
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              onSortChanged: (s) => setState(() => _sortOption = s),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: tasksAsync.when(
                loading: () => const _TasksShimmerList(),
                error: (err, stack) => _ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.refresh(tasksProvider),
                ),
                data: (rawTasks) {
                  if (rawTasks.isEmpty) {
                    return const EmptyState(
                      icon: Icons.assignment_late_outlined,
                      title: 'No tasks assigned',
                      description:
                          'You currently have no active task assignments in your queue.',
                    );
                  }

                  final displayedTasks = _filterAndSort(rawTasks);

                  if (displayedTasks.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching tasks',
                      description:
                          'No tasks matched "$_searchQuery". Try a different keyword.',
                      action: AppButton(
                        label: 'Clear Search',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => setState(() => _searchQuery = ''),
                      ),
                    );
                  }

                  return _ResponsiveTaskGrid(tasks: displayedTasks);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load tasks',
        description: message,
        action: AppButton(
          label: 'Retry Loading',
          prefixIcon: Icons.refresh_rounded,
          onPressed: onRetry,
        ),
      ),
    );
  }
}

class _ResponsiveTaskGrid extends StatelessWidget {
  const _ResponsiveTaskGrid({required this.tasks});
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: (context) => ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.base),
        itemBuilder: (context, index) => AnimatedTaskItem(
          index: index,
          child: TaskCard(task: tasks[index]),
        ),
      ),
      desktop: (context) => GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.base,
          mainAxisSpacing: AppSpacing.base,
          mainAxisExtent: 150,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) => AnimatedTaskItem(
          index: index,
          child: TaskCard(task: tasks[index]),
        ),
      ),
    );
  }
}

class AnimatedTaskItem extends StatelessWidget {
  const AnimatedTaskItem({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _TasksShimmerList extends StatelessWidget {
  const _TasksShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.base),
      itemBuilder: (context, index) => const AppShimmer(
        width: double.infinity,
        height: 140,
        borderRadius: 20,
      ),
    );
  }
}

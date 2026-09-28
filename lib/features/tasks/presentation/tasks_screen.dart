import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_shimmer.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/models/task.dart';
import '../../auth/presentation/providers/role_provider.dart';
import '../domain/models/sprint_models.dart';
import 'providers/tasks_provider.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_bar.dart';

/// Interactive Tasks & Operations Board supporting Multi-App Sprints, Workload Isolation, and Day-by-Day tracking.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _searchQuery = '';
  TaskSortOption _sortOption = TaskSortOption.deadline;
  TaskStatusFilter _statusFilter = TaskStatusFilter.active;
  SprintApp _selectedApp = SprintApp.all;
  SprintMember _selectedMember = SprintMember.all;
  SprintDay _selectedDay = SprintDay.all;

  List<Task> _filterAndSort(List<Task> rawTasks, {required bool isManager}) {
    var filtered = rawTasks.where((t) {
      // 1. Status Filter
      if (_statusFilter == TaskStatusFilter.active) {
        if (t.status == TaskStatus.submitted || t.status == TaskStatus.approved) {
          return false;
        }
      } else if (_statusFilter == TaskStatusFilter.submitted) {
        if (t.status != TaskStatus.submitted) return false;
      } else if (_statusFilter == TaskStatusFilter.approved) {
        if (t.status != TaskStatus.approved) return false;
      }

      // 2. Multi-App Sprint Filter
      if (_selectedApp != SprintApp.all) {
        final app = SprintApp.fromTask(t);
        if (app != _selectedApp) return false;
      }

      // 3. Employee Workload Filter (Only applicable to managers)
      if (isManager && _selectedMember != SprintMember.all) {
        if (!_selectedMember.matches(t.assignedTo)) return false;
      }

      // 4. Day-by-Day Sprint Selector
      if (_selectedDay != SprintDay.all) {
        final day = SprintDay.fromTask(t);
        if (day != _selectedDay) return false;
      }

      // 5. Search Query
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          (t.githubRepo?.toLowerCase().contains(q) ?? false) ||
          (t.branchName?.toLowerCase().contains(q) ?? false) ||
          (t.description?.toLowerCase().contains(q) ?? false) ||
          (t.aiPrompt?.toLowerCase().contains(q) ?? false);
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

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedApp = SprintApp.all;
      _selectedMember = SprintMember.all;
      _selectedDay = SprintDay.all;
      _statusFilter = TaskStatusFilter.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final roleAsync = ref.watch(roleProvider);
    final isManager = roleAsync.valueOrNull?.isManager ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tasks & Operations Board',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2-Week Sprint across Fitora, Planly, AI PDF Maker & Resume Brain',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      label: 'Sprint Calendar',
                      prefixIcon: Icons.calendar_month_rounded,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                      onPressed: () => context.go(AppRoutes.calendar),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    tasksAsync.maybeWhen(
                      data: (tasks) {
                        final activeCount = tasks
                            .where((t) =>
                                t.status != TaskStatus.submitted &&
                                t.status != TaskStatus.approved)
                            .length;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.brandBlue.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.brandCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$activeCount Active Tasks',
                                style: const TextStyle(
                                  color: AppColors.brandCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Comprehensive Multi-Dimensional Sprint Filter Bar
            TaskFilterBar(
              searchQuery: _searchQuery,
              selectedSort: _sortOption,
              selectedStatus: _statusFilter,
              selectedApp: _selectedApp,
              selectedMember: _selectedMember,
              selectedDay: _selectedDay,
              showMemberFilter: isManager,
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              onSortChanged: (s) => setState(() => _sortOption = s),
              onStatusChanged: (status) => setState(() => _statusFilter = status),
              onAppChanged: (app) => setState(() => _selectedApp = app),
              onMemberChanged: isManager
                  ? (member) => setState(() => _selectedMember = member)
                  : null,
              onDayChanged: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Task List View
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
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'No tasks assigned',
                      description: 'Your task queue is completely clear.',
                    );
                  }

                  final displayedTasks =
                      _filterAndSort(rawTasks, isManager: isManager);

                  if (displayedTasks.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching sprint tasks',
                      description:
                          'No assignments matched your active filters. Try refining your selection.',
                      action: AppButton(
                        label: 'Reset Filters',
                        variant: AppButtonVariant.secondary,
                        onPressed: _clearFilters,
                      ),
                    );
                  }

                  return _TasksListView(tasks: displayedTasks);
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

class _TasksListView extends StatelessWidget {
  const _TasksListView({required this.tasks});
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AnimatedTaskItem(
        index: index,
        child: TaskCard(task: tasks[index]),
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
      duration: Duration(milliseconds: 250 + (index * 40).clamp(0, 350)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
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
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => const AppShimmer(
        width: double.infinity,
        height: 150,
        borderRadius: 20,
      ),
    );
  }
}

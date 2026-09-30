import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/operations_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

/// Interactive Kanban Task Board Screen with multi-criteria filtering and status transitions.
class TasksBoardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onCreateTask;

  const TasksBoardScreen({super.key, this.onCreateTask});

  @override
  ConsumerState<TasksBoardScreen> createState() => _TasksBoardScreenState();
}

class _TasksBoardScreenState extends ConsumerState<TasksBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mobileTabController;

  @override
  void initState() {
    super.initState();
    _mobileTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _mobileTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final isMobile = AppBreakpoints.isMobile(context);

    if (tasksState.isLoading && tasksState.tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (tasksState.error != null && tasksState.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load tasks',
                style: AppTypography.h3,
              ),
              const SizedBox(height: 8),
              Text(
                tasksState.error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.read(tasksProvider.notifier).loadTasks(refresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredTasks = tasksState.filteredTasks;
    final hasActiveFilters = tasksState.hasActiveFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Task Filter Bar with multi-criteria selectors and active badges
        const TaskFilterBar(),
        const SizedBox(height: 18),

        // 2. Filtered Empty State OR Kanban Board
        if (filteredTasks.isEmpty && hasActiveFilters)
          _buildFilteredEmptyState(context)
        else if (isMobile)
          _buildMobileKanban(tasksState)
        else
          _buildDesktopKanban(tasksState),
      ],
    );
  }

  Widget _buildFilteredEmptyState(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks match the selected filters',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try relaxing your filter combination or clear all active filters to view all tasks.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('clear_all_filters_empty_button'),
              onPressed: () {
                ref.read(tasksProvider.notifier).clearAllFilters();
              },
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: const Text('Clear all filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopKanban(TasksState tasksState) {
    final backlogTasks = tasksState.backlogTasks;
    final inProgressTasks = tasksState.inProgressTasks;
    final underReviewTasks = tasksState.underReviewTasks;
    final doneTasks = tasksState.doneTasks;

    // Use a horizontally scrollable container if space is tight, or flexible row on wide screens
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Total columns = 4, spacing = 16 * 3 = 48
        final columnWidth = (availableWidth - 48) / 4;
        const minColWidth = 270.0;

        if (columnWidth < minColWidth) {
          // Horizontal scroll layout
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn(
                  columnKey: const Key('column_backlog'),
                  title: 'Backlog',
                  status: 'backlog',
                  icon: Icons.inbox_rounded,
                  color: AppColors.textMuted,
                  tasks: backlogTasks,
                  width: minColWidth,
                ),
                const SizedBox(width: 16),
                _buildKanbanColumn(
                  columnKey: const Key('column_in_progress'),
                  title: 'In Progress',
                  status: 'in_progress',
                  icon: Icons.autorenew_rounded,
                  color: AppColors.primary,
                  tasks: inProgressTasks,
                  width: minColWidth,
                ),
                const SizedBox(width: 16),
                _buildKanbanColumn(
                  columnKey: const Key('column_under_review'),
                  title: 'Under Review',
                  status: 'under_review',
                  icon: Icons.rate_review_rounded,
                  color: AppColors.warning,
                  tasks: underReviewTasks,
                  width: minColWidth,
                ),
                const SizedBox(width: 16),
                _buildKanbanColumn(
                  columnKey: const Key('column_done'),
                  title: 'Done',
                  status: 'done',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  tasks: doneTasks,
                  width: minColWidth,
                ),
              ],
            ),
          );
        }

        // Side-by-side row
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildKanbanColumn(
                columnKey: const Key('column_backlog'),
                title: 'Backlog',
                status: 'backlog',
                icon: Icons.inbox_rounded,
                color: AppColors.textMuted,
                tasks: backlogTasks,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKanbanColumn(
                columnKey: const Key('column_in_progress'),
                title: 'In Progress',
                status: 'in_progress',
                icon: Icons.autorenew_rounded,
                color: AppColors.primary,
                tasks: inProgressTasks,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKanbanColumn(
                columnKey: const Key('column_under_review'),
                title: 'Under Review',
                status: 'under_review',
                icon: Icons.rate_review_rounded,
                color: AppColors.warning,
                tasks: underReviewTasks,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKanbanColumn(
                columnKey: const Key('column_done'),
                title: 'Done',
                status: 'done',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                tasks: doneTasks,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileKanban(TasksState tasksState) {
    final backlogTasks = tasksState.backlogTasks;
    final inProgressTasks = tasksState.inProgressTasks;
    final underReviewTasks = tasksState.underReviewTasks;
    final doneTasks = tasksState.doneTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TabBar(
            controller: _mobileTabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Backlog (${backlogTasks.length})'),
              Tab(text: 'In Progress (${inProgressTasks.length})'),
              Tab(text: 'Review (${underReviewTasks.length})'),
              Tab(text: 'Done (${doneTasks.length})'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 520,
          child: TabBarView(
            controller: _mobileTabController,
            children: [
              _buildColumnCardList(
                columnKey: const Key('column_backlog'),
                status: 'backlog',
                title: 'Backlog',
                tasks: backlogTasks,
              ),
              _buildColumnCardList(
                columnKey: const Key('column_in_progress'),
                status: 'in_progress',
                title: 'In Progress',
                tasks: inProgressTasks,
              ),
              _buildColumnCardList(
                columnKey: const Key('column_under_review'),
                status: 'under_review',
                title: 'Under Review',
                tasks: underReviewTasks,
              ),
              _buildColumnCardList(
                columnKey: const Key('column_done'),
                status: 'done',
                title: 'Done',
                tasks: doneTasks,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanColumn({
    required Key columnKey,
    required String title,
    required String status,
    required IconData icon,
    required Color color,
    required List<TaskItem> tasks,
    double? width,
  }) {
    Widget columnContent = Container(
      key: columnKey,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards list
          Padding(
            padding: const EdgeInsets.all(10),
            child: tasks.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: Text(
                      'No tasks in this stage',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Column(
                    children: tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskCard(
                          key: Key('task_card_${task.id}'),
                          task: task,
                          onStatusChanged: (newStatus) {
                            ref
                                .read(tasksProvider.notifier)
                                .updateTaskStatus(
                                  taskId: task.id,
                                  status: newStatus,
                                );
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );

    return columnContent;
  }

  Widget _buildColumnCardList({
    required Key columnKey,
    required String status,
    required String title,
    required List<TaskItem> tasks,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No $title tasks',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      key: columnKey,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TaskCard(
            key: Key('task_card_${task.id}'),
            task: task,
            onStatusChanged: (newStatus) {
              ref.read(tasksProvider.notifier).updateTaskStatus(
                    taskId: task.id,
                    status: newStatus,
                  );
            },
          ),
        );
      },
    );
  }
}

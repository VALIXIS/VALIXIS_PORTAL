import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/realtime_sync_service.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/models/task.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/manager_shimmer.dart';
import 'widgets/manager_task_card.dart';
import 'widgets/manager_task_dialogs.dart';

/// Mobile-optimized Executive Manager Tasks Screen for monitoring, filtering, and reassigning tasks.
class ManagerTasksScreen extends ConsumerStatefulWidget {
  const ManagerTasksScreen({super.key, this.initialStatusFilter});

  final String? initialStatusFilter;

  @override
  ConsumerState<ManagerTasksScreen> createState() => _ManagerTasksScreenState();
}

class _ManagerTasksScreenState extends ConsumerState<ManagerTasksScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedStatus;
  String _selectedRepo = 'all';
  String _selectedSortField = 'deadline';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatusFilter ?? 'all';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.read(realtimeSyncProvider.notifier).forceRefresh();
  }

  List<Task> _filterTasks(List<Task> rawTasks) {
    return rawTasks.where((task) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(q);
        final matchRepo = (task.githubRepo ?? '').toLowerCase().contains(q);
        final matchBranch = (task.branchName ?? '').toLowerCase().contains(q);
        final matchAssignee = task.assignedTo.toLowerCase().contains(q);
        if (!matchTitle && !matchRepo && !matchBranch && !matchAssignee) return false;
      }

      if (_selectedStatus != 'all') {
        final now = DateTime.now();
        if (_selectedStatus == 'active') {
          if (task.status.isCompleted) return false;
        } else if (_selectedStatus == 'overdue') {
          if (!task.deadline.isBefore(now) || task.status.isCompleted) return false;
        } else if (_selectedStatus == 'assigned') {
          if (task.status != TaskStatus.assigned) return false;
        } else if (_selectedStatus == 'in_progress') {
          if (task.status != TaskStatus.inProgress) return false;
        } else if (_selectedStatus == 'submitted') {
          if (task.status != TaskStatus.submitted) return false;
        } else if (_selectedStatus == 'approved' || _selectedStatus == 'completed') {
          if (task.status != TaskStatus.approved) return false;
        } else if (_selectedStatus == 'rejected') {
          if (task.status != TaskStatus.rejected) return false;
        }
      }

      if (_selectedRepo != 'all') {
        final repo = task.githubRepo ?? 'VALIXIS_PORTAL';
        if (repo != _selectedRepo) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        int cmp = 0;
        switch (_selectedSortField) {
          case 'title':
            cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
            break;
          case 'priority':
            int priorityWeight(TaskPriority p) => switch (p) {
                  TaskPriority.critical => 4,
                  TaskPriority.high => 3,
                  TaskPriority.medium => 2,
                  TaskPriority.low => 1,
                };
            cmp = priorityWeight(a.priority).compareTo(priorityWeight(b.priority));
            break;
          case 'assignment':
            final aName = a.assignedTo.isEmpty || a.assignedTo == 'Unassigned'
                ? 'z_unassigned'
                : a.assignedTo.toLowerCase();
            final bName = b.assignedTo.isEmpty || b.assignedTo == 'Unassigned'
                ? 'z_unassigned'
                : b.assignedTo.toLowerCase();
            cmp = aName.compareTo(bName);
            break;
          case 'deadline':
          default:
            cmp = a.deadline.compareTo(b.deadline);
            break;
        }
        return _sortAscending ? cmp : -cmp;
      });
  }

  Future<void> _onReassign(Task task, List<Map<String, dynamic>> employees) async {
    final ok = await ManagerTaskDialogs.showReassignDialog(
      context: context,
      task: task,
      employees: employees,
      managerRepo: ref.read(managerRepositoryProvider),
    );
    if (ok == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" reassignment updated!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _refresh();
    }
  }

  Future<void> _onUnassign(Task task) async {
    final ok = await ManagerTaskDialogs.showUnassignDialog(
      context: context,
      task: task,
      managerRepo: ref.read(managerRepositoryProvider),
    );
    if (ok == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" unassigned!'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.brandCyan,
        backgroundColor: AppColors.surfaceElevated,
        onRefresh: () async {
          _refresh();
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: metricsAsync.when(
          loading: () => const ManagerShimmer(),
          error: (err, _) => Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Failed to load manager tasks',
                description: err.toString(),
                action: AppButton(
                  label: 'Retry',
                  prefixIcon: Icons.refresh_rounded,
                  onPressed: _refresh,
                ),
              ),
            ),
          ),
          data: (metrics) {
            final allTasks = metrics.recentTasks;
            final filteredTasks = _filterTasks(allTasks);
            final repos = allTasks
                .map((t) => t.githubRepo ?? 'VALIXIS_PORTAL')
                .toSet()
                .toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen Header (Monitoring only - strictly NO create task)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manager Tasks',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${filteredTasks.length} ${filteredTasks.length == 1 ? 'task' : 'tasks'} found',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Sort toggle button
                      PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.sort_rounded, size: 18, color: AppColors.brandCyan),
                        ),
                        color: AppColors.surfaceElevated,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          if (val == _selectedSortField) {
                            setState(() => _sortAscending = !_sortAscending);
                          } else {
                            setState(() {
                              _selectedSortField = val;
                              _sortAscending = true;
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'deadline',
                            child: Row(
                              children: [
                                Icon(Icons.alarm_rounded, size: 16, color: _selectedSortField == 'deadline' ? AppColors.brandCyan : AppColors.textMuted),
                                const SizedBox(width: 8),
                                Text('Deadline ${_selectedSortField == 'deadline' ? (_sortAscending ? '(Soonest)' : '(Latest)') : ''}'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'priority',
                            child: Row(
                              children: [
                                Icon(Icons.flag_rounded, size: 16, color: _selectedSortField == 'priority' ? AppColors.brandCyan : AppColors.textMuted),
                                const SizedBox(width: 8),
                                Text('Priority ${_selectedSortField == 'priority' ? (_sortAscending ? '(Asc)' : '(Desc)') : ''}'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'title',
                            child: Row(
                              children: [
                                Icon(Icons.title_rounded, size: 16, color: _selectedSortField == 'title' ? AppColors.brandCyan : AppColors.textMuted),
                                const SizedBox(width: 8),
                                const Text('Task Title'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'assignment',
                            child: Row(
                              children: [
                                Icon(Icons.person_rounded, size: 16, color: _selectedSortField == 'assignment' ? AppColors.brandCyan : AppColors.textMuted),
                                const SizedBox(width: 8),
                                const Text('Assigned Employee'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Search TextField
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search tasks, assignees, branches...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandCyan, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Filter Chips Carousel
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All (${allTasks.length})',
                          isSelected: _selectedStatus == 'all',
                          onTap: () => setState(() => _selectedStatus = 'all'),
                        ),
                        _FilterChip(
                          label: 'Active',
                          isSelected: _selectedStatus == 'active',
                          onTap: () => setState(() => _selectedStatus = 'active'),
                        ),
                        _FilterChip(
                          label: 'In Progress',
                          isSelected: _selectedStatus == 'in_progress',
                          onTap: () => setState(() => _selectedStatus = 'in_progress'),
                        ),
                        _FilterChip(
                          label: 'Submitted',
                          isSelected: _selectedStatus == 'submitted',
                          onTap: () => setState(() => _selectedStatus = 'submitted'),
                        ),
                        _FilterChip(
                          label: 'Assigned',
                          isSelected: _selectedStatus == 'assigned',
                          onTap: () => setState(() => _selectedStatus = 'assigned'),
                        ),
                        _FilterChip(
                          label: 'Completed',
                          isSelected: _selectedStatus == 'completed' || _selectedStatus == 'approved',
                          onTap: () => setState(() => _selectedStatus = 'completed'),
                        ),
                        _FilterChip(
                          label: 'Overdue',
                          isSelected: _selectedStatus == 'overdue',
                          isDanger: true,
                          onTap: () => setState(() => _selectedStatus = 'overdue'),
                        ),
                      ],
                    ),
                  ),
                  if (repos.length > 1) ...[
                    const SizedBox(height: AppSpacing.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _RepoChip(
                            label: 'All Repositories',
                            isSelected: _selectedRepo == 'all',
                            onTap: () => setState(() => _selectedRepo = 'all'),
                          ),
                          ...repos.map((r) => _RepoChip(
                                label: r,
                                isSelected: _selectedRepo == r,
                                onTap: () => setState(() => _selectedRepo = r),
                              )),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  // Task List
                  if (filteredTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl2),
                      child: Center(
                        child: EmptyState(
                          icon: Icons.filter_alt_off_rounded,
                          title: 'No Tasks Found',
                          description: 'No tasks match your search query and selected filter options.',
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTasks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return ManagerTaskCard(
                          task: task,
                          onReassign: () => _onReassign(task, metrics.allEmployees),
                          onUnassign: () => _onUnassign(task),
                        );
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDanger ? AppColors.error : AppColors.brandCyan;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withAlpha(35) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? activeColor : AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? (isDanger ? AppColors.error : Colors.white) : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepoChip extends StatelessWidget {
  const _RepoChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandBlue.withAlpha(30) : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.brandBlue : AppColors.glassBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_outlined, size: 11, color: isSelected ? AppColors.brandCyan : AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.brandCyan : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

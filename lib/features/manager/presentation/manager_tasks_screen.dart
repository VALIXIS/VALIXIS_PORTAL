import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/realtime_sync_service.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/models/task.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../tasks/domain/models/sprint_models.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/manager_shimmer.dart';
import 'widgets/manager_task_card.dart';
import 'widgets/manager_task_dialogs.dart';
import 'widgets/manager_tasks_table.dart';

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
  SprintApp _selectedApp = SprintApp.all;
  SprintMember _selectedMember = SprintMember.all;
  final SprintDay _selectedDay = SprintDay.all;
  String _selectedSortField = 'deadline';
  bool _sortAscending = true;
  bool _onlyAssignedToMe = false;

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
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final userEmail = currentUser?.email?.toLowerCase().trim() ?? '';
    final userId = currentUser?.id.toLowerCase().trim() ?? '';

    return rawTasks.where((task) {
      if (_onlyAssignedToMe) {
        final assignee = task.assignedTo.toLowerCase().trim();
        final matches = (userEmail.isNotEmpty && assignee.contains(userEmail)) ||
            (userId.isNotEmpty && assignee.contains(userId)) ||
            (userEmail.isNotEmpty && assignee.contains(userEmail.split('@').first));
        if (!matches) return false;
      }

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

      if (_selectedApp != SprintApp.all) {
        final app = SprintApp.fromTask(task);
        if (app != _selectedApp) return false;
      }

      if (_selectedMember != SprintMember.all) {
        if (!_selectedMember.matches(task.assignedTo)) return false;
      }

      if (_selectedDay != SprintDay.all) {
        final day = SprintDay.fromTask(task);
        if (day != _selectedDay) return false;
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

  Future<void> _onEdit(Task task) async {
    final ok = await ManagerTaskDialogs.showEditTaskDialog(
      context: context,
      task: task,
      managerRepo: ref.read(managerRepositoryProvider),
    );
    if (ok == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" updated successfully!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _refresh();
    }
  }

  Future<void> _onDelete(Task task) async {
    final ok = await ManagerTaskDialogs.showDeleteDialog(
      context: context,
      task: task,
      managerRepo: ref.read(managerRepositoryProvider),
    );
    if (ok == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted!'),
            backgroundColor: AppColors.error,
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

            final isDesktop = MediaQuery.of(context).size.width >= 900;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? AppSpacing.xl : AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
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
                            'Tasks',
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
                      // Header Actions: Sprint Calendar + Sort toggle button
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
                          isSelected: !_onlyAssignedToMe && _selectedStatus == 'all',
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'all';
                          }),
                        ),
                        _FilterChip(
                          label: 'Assigned to Me',
                          isSelected: _onlyAssignedToMe,
                          onTap: () => setState(() => _onlyAssignedToMe = !_onlyAssignedToMe),
                        ),
                        _FilterChip(
                          label: 'Active',
                          isSelected: !_onlyAssignedToMe && _selectedStatus == 'active',
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'active';
                          }),
                        ),
                        _FilterChip(
                          label: 'In Progress',
                          isSelected: !_onlyAssignedToMe && _selectedStatus == 'in_progress',
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'in_progress';
                          }),
                        ),
                        _FilterChip(
                          label: 'Submitted',
                          isSelected: !_onlyAssignedToMe && _selectedStatus == 'submitted',
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'submitted';
                          }),
                        ),
                        _FilterChip(
                          label: 'Assigned',
                          isSelected: !_onlyAssignedToMe && _selectedStatus == 'assigned',
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'assigned';
                          }),
                        ),
                        _FilterChip(
                          label: 'Completed',
                          isSelected: !_onlyAssignedToMe && (_selectedStatus == 'completed' || _selectedStatus == 'approved'),
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'completed';
                          }),
                        ),
                        _FilterChip(
                          label: 'Overdue',
                          isSelected: !_onlyAssignedToMe && _selectedStatus == 'overdue',
                          isDanger: true,
                          onTap: () => setState(() {
                            _onlyAssignedToMe = false;
                            _selectedStatus = 'overdue';
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Sprint Apps Filter Row
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: SprintApp.values.map((app) {
                        final isSelected = _selectedApp == app;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _selectedApp = app),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? app.color.withAlpha(40)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? app.color : AppColors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(app.icon, size: 13, color: isSelected ? app.color : AppColors.textSecondary),
                                  const SizedBox(width: 5),
                                  Text(
                                    app.displayName,
                                    style: TextStyle(
                                      color: isSelected ? app.color : AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Sprint Member Workload & Day-by-Day Selector Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        // Member Workload selector
                        ...SprintMember.values.map((member) {
                          final isSelected = _selectedMember == member;
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: InkWell(
                              onTap: () => setState(() => _selectedMember = member),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? member.color.withAlpha(35) : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? member.color : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (member != SprintMember.all) ...[
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: member.color.withAlpha(50),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            member.initial,
                                            style: TextStyle(
                                              color: member.color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      member.name,
                                      style: TextStyle(
                                        color: isSelected ? member.color : AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
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
                  else if (MediaQuery.of(context).size.width >= 768)
                    ManagerTasksTable(
                      tasks: filteredTasks,
                      sortField: _selectedSortField,
                      sortAscending: _sortAscending,
                      onSort: (field, asc) {
                        setState(() {
                          _selectedSortField = field;
                          _sortAscending = asc;
                        });
                      },
                      onReassign: (task) => _onReassign(task, metrics.allEmployees),
                      onUnassign: (task) => _onUnassign(task),
                      onDelete: (task) => _onDelete(task),
                      onEdit: (task) => _onEdit(task),
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
                          onEdit: () => _onEdit(task),
                        );
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/layout/responsive_layout.dart';
import '../../../shared/models/task.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../tasks/presentation/providers/tasks_provider.dart';
import 'providers/employee_management_provider.dart';
import 'providers/manager_dashboard_provider.dart';
import 'widgets/manager_shimmer.dart';
import 'widgets/manager_task_dialogs.dart';
import 'widgets/manager_tasks_filter_bar.dart';
import 'widgets/manager_tasks_table.dart';

/// Dedicated Manager Tasks Screen supporting full assignment state management, search, filtering, and live actions.
class ManagerTasksScreen extends ConsumerStatefulWidget {
  const ManagerTasksScreen({super.key, this.initialStatusFilter});

  final String? initialStatusFilter;

  @override
  ConsumerState<ManagerTasksScreen> createState() => _ManagerTasksScreenState();
}

class _ManagerTasksScreenState extends ConsumerState<ManagerTasksScreen> {
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

  void _refreshAllProviders() {
    ref.invalidate(managerDashboardProvider);
    ref.invalidate(employeeManagementProvider);
    ref.invalidate(tasksProvider);
    ref.invalidate(dashboardProvider);
  }

  List<Task> _filterTasks(List<Task> rawTasks) {
    return rawTasks.where((task) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(q);
        final matchRepo = (task.githubRepo ?? '').toLowerCase().contains(q);
        final matchBranch = (task.branchName ?? '').toLowerCase().contains(q);
        if (!matchTitle && !matchRepo && !matchBranch) return false;
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
        } else if (_selectedStatus == 'approved') {
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
          case 'repo':
            cmp = (a.githubRepo ?? 'VALIXIS_PORTAL').toLowerCase().compareTo((b.githubRepo ?? 'VALIXIS_PORTAL').toLowerCase());
            break;
          case 'priority':
            int priorityWeight(TaskPriority p) {
              return switch (p) {
                TaskPriority.critical => 4,
                TaskPriority.high => 3,
                TaskPriority.medium => 2,
                TaskPriority.low => 1,
              };
            }
            cmp = priorityWeight(a.priority).compareTo(priorityWeight(b.priority));
            break;
          case 'assignment':
            final aName = a.assignedTo.isEmpty || a.assignedTo == 'Unassigned' ? 'z_unassigned' : a.assignedTo.toLowerCase();
            final bName = b.assignedTo.isEmpty || b.assignedTo == 'Unassigned' ? 'z_unassigned' : b.assignedTo.toLowerCase();
            cmp = aName.compareTo(bName);
            break;
          case 'pr':
            final aHasPr = (a.prUrl != null && a.prUrl!.isNotEmpty) ? 1 : 0;
            final bHasPr = (b.prUrl != null && b.prUrl!.isNotEmpty) ? 1 : 0;
            cmp = aHasPr.compareTo(bHasPr);
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
            content: Text('Task "${task.title}" reassignment initiated!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      Future.delayed(const Duration(milliseconds: 300), _refreshAllProviders);
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
      Future.delayed(const Duration(milliseconds: 300), _refreshAllProviders);
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
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      Future.delayed(const Duration(milliseconds: 300), _refreshAllProviders);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: metricsAsync.when(
        loading: () => const ManagerShimmer(),
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load manager tasks',
            description: err.toString(),
            action: AppButton(
              label: 'Retry',
              prefixIcon: Icons.refresh_rounded,
              onPressed: _refreshAllProviders,
            ),
          ),
        ),
        data: (metrics) {
          final allTasks = metrics.recentTasks;
          final filteredTasks = _filterTasks(allTasks);
          final repos = allTasks.map((t) => t.githubRepo ?? 'VALIXIS_PORTAL').toSet().toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Manager Tasks Overview', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        SizedBox(height: 2),
                        Text('Manage, reassign, unassign, and delete engineering tasks across teams', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                    AppButton(
                      label: 'Create New Task',
                      prefixIcon: Icons.add_rounded,
                      onPressed: () => context.go(AppRoutes.managerCreateTask),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                ManagerTasksFilterBar(
                  searchQuery: _searchQuery,
                  selectedStatus: _selectedStatus,
                  selectedRepo: _selectedRepo,
                  selectedSortField: _selectedSortField,
                  sortAscending: _sortAscending,
                  repositories: repos,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onStatusChanged: (s) => setState(() => _selectedStatus = s),
                  onRepoChanged: (r) => setState(() => _selectedRepo = r),
                  onSortFieldChanged: (f) => setState(() => _selectedSortField = f),
                  onSortToggle: () => setState(() => _sortAscending = !_sortAscending),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (filteredTasks.isEmpty)
                  const GlassCard(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: Text('No tasks match the selected filters.', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  ResponsiveLayout(
                    mobile: (context) => _MobileTasksList(
                      tasks: filteredTasks,
                      onReassign: (t) => _onReassign(t, metrics.allEmployees),
                      onUnassign: _onUnassign,
                      onDelete: _onDelete,
                    ),
                    desktop: (context) => ManagerTasksTable(
                      tasks: filteredTasks,
                      sortField: _selectedSortField,
                      sortAscending: _sortAscending,
                      onSort: (field, asc) {
                        setState(() {
                          _selectedSortField = field;
                          _sortAscending = asc;
                        });
                      },
                      onReassign: (t) => _onReassign(t, metrics.allEmployees),
                      onUnassign: _onUnassign,
                      onDelete: _onDelete,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileTasksList extends StatelessWidget {
  const _MobileTasksList({
    required this.tasks,
    required this.onReassign,
    required this.onUnassign,
    required this.onDelete,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onReassign;
  final ValueChanged<Task> onUnassign;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks.map((t) {
        final isAssigned = t.assignedTo.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(t.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16))),
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error), onPressed: () => onDelete(t)),
                  ],
                ),
                Text(t.githubRepo ?? 'VALIXIS_PORTAL', style: const TextStyle(color: AppColors.brandBlue, fontSize: 12)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isAssigned ? 'Assigned: ${t.assignedTo}' : 'Unassigned', style: TextStyle(color: isAssigned ? AppColors.textPrimary : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        TextButton(onPressed: () => onReassign(t), child: const Text('Reassign')),
                        if (isAssigned) TextButton(onPressed: () => onUnassign(t), child: const Text('Unassign', style: TextStyle(color: AppColors.warning))),
                        AppButton(label: 'View', size: AppButtonSize.small, onPressed: () => context.go('/tasks/${t.id}')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

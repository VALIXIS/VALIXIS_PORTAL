import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../team/presentation/providers/team_provider.dart';
import '../providers/operations_provider.dart';

/// Interactive filter toolbar allowing multi-criteria filtering by Project,
/// Assignee, Priority, Status, and search keywords.
class TaskFilterBar extends ConsumerStatefulWidget {
  const TaskFilterBar({super.key});

  @override
  ConsumerState<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends ConsumerState<TaskFilterBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final projectsState = ref.watch(projectsProvider);
    final teamState = ref.watch(teamMembersProvider);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Search + Dropdowns
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Input
              SizedBox(
                width: 240,
                height: 38,
                child: TextField(
                  key: const Key('task_search_field'),
                  controller: _searchController,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
                  onChanged: (val) {
                    ref.read(tasksProvider.notifier).setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 16),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 14),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(tasksProvider.notifier).setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),

              // Project Filter Dropdown
              _buildDropdown(
                key: const Key('filter_project_select'),
                label: 'Project',
                value: tasksState.filterProjectId ?? 'all',
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Projects')),
                  ...projectsState.projects.map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (val) {
                  ref.read(tasksProvider.notifier).setProjectFilter(val);
                },
              ),

              // Assignee Filter Dropdown
              _buildDropdown(
                key: const Key('filter_assignee_select'),
                label: 'Assignee',
                value: tasksState.filterAssigneeId ?? 'all',
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Assignees')),
                  ...teamState.members.map(
                    (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (val) {
                  ref.read(tasksProvider.notifier).setAssigneeFilter(val);
                },
              ),

              // Priority Filter Dropdown
              _buildDropdown(
                key: const Key('filter_priority_select'),
                label: 'Priority',
                value: tasksState.filterPriority ?? 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                  DropdownMenuItem(value: 'critical', child: Text('Critical (P0)')),
                  DropdownMenuItem(value: 'high', child: Text('High (P1)')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium (P2)')),
                  DropdownMenuItem(value: 'low', child: Text('Low (P3)')),
                ],
                onChanged: (val) {
                  ref.read(tasksProvider.notifier).setPriorityFilter(val);
                },
              ),

              // Status Filter Dropdown
              _buildDropdown(
                key: const Key('filter_status_select'),
                label: 'Status',
                value: tasksState.filterStatus ?? 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'backlog', child: Text('Backlog')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'under_review', child: Text('Under Review')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: (val) {
                  ref.read(tasksProvider.notifier).setStatusFilter(val);
                },
              ),

              // Clear All Filters Button
              if (tasksState.hasActiveFilters) ...[
                TextButton.icon(
                  key: const Key('clear_all_filters_button'),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(tasksProvider.notifier).clearAllFilters();
                  },
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 14, color: AppColors.error),
                  label: Text(
                    'Clear All (${tasksState.activeFilterCount})',
                    style: AppTypography.label.copyWith(color: AppColors.error, fontSize: 11.5),
                  ),
                ),
              ],
            ],
          ),

          // Active filter tags strip (if any active)
          if (tasksState.hasActiveFilters) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (tasksState.filterProjectId != null && tasksState.filterProjectId != 'all')
                  _buildActiveChip(
                    'Project: ${_lookupProjectName(projectsState.projects, tasksState.filterProjectId!)}',
                    () => ref.read(tasksProvider.notifier).clearFilter('project'),
                    key: const Key('active_chip_project'),
                  ),
                if (tasksState.filterAssigneeId != null && tasksState.filterAssigneeId != 'all')
                  _buildActiveChip(
                    'Assignee: ${_lookupMemberName(teamState.members, tasksState.filterAssigneeId!)}',
                    () => ref.read(tasksProvider.notifier).clearFilter('assignee'),
                    key: const Key('active_chip_assignee'),
                  ),
                if (tasksState.filterPriority != null && tasksState.filterPriority != 'all')
                  _buildActiveChip(
                    'Priority: ${tasksState.filterPriority!.toUpperCase()}',
                    () => ref.read(tasksProvider.notifier).clearFilter('priority'),
                    key: const Key('active_chip_priority'),
                  ),
                if (tasksState.filterStatus != null && tasksState.filterStatus != 'all')
                  _buildActiveChip(
                    'Status: ${_formatStatus(tasksState.filterStatus!)}',
                    () => ref.read(tasksProvider.notifier).clearFilter('status'),
                    key: const Key('active_chip_status'),
                  ),
                if (tasksState.searchQuery.isNotEmpty)
                  _buildActiveChip(
                    'Search: "${tasksState.searchQuery}"',
                    () {
                      _searchController.clear();
                      ref.read(tasksProvider.notifier).clearFilter('search');
                    },
                    key: const Key('active_chip_search'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required Key key,
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value != 'all'
              ? AppColors.primary.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: key,
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
          dropdownColor: AppColors.surfaceElevated,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 12,
            color: value != 'all' ? AppColors.primary : AppColors.textPrimary,
            fontWeight: value != 'all' ? FontWeight.w600 : FontWeight.w400,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.only(left: 8, right: 4, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _lookupProjectName(List<Project> projects, String id) {
    try {
      return projects.firstWhere((p) => p.id == id).name;
    } catch (_) {
      return 'Project';
    }
  }

  String _lookupMemberName(List<dynamic> members, String id) {
    try {
      return members.firstWhere((m) => m.id == id).name;
    } catch (_) {
      return 'Member';
    }
  }

  String _formatStatus(String s) {
    switch (s) {
      case 'in_progress':
        return 'In Progress';
      case 'under_review':
        return 'Under Review';
      case 'done':
        return 'Done';
      case 'backlog':
      default:
        return 'Backlog';
    }
  }
}

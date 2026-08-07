import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_text_field.dart';

/// Filter bar for Manager Tasks supporting search, status filter, repo filter, and deadline sorting.
class ManagerTasksFilterBar extends StatelessWidget {
  const ManagerTasksFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedRepo,
    required this.sortAscending,
    required this.repositories,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onRepoChanged,
    required this.onSortToggle,
  });

  final String searchQuery;
  final String selectedStatus;
  final String selectedRepo;
  final bool sortAscending;
  final List<String> repositories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRepoChanged;
  final VoidCallback onSortToggle;

  @override
  Widget build(BuildContext context) {
    final statusItems = const [
      DropdownMenuItem(value: 'all', child: Text('All Statuses')),
      DropdownMenuItem(value: 'active', child: Text('Active Tasks')),
      DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
      DropdownMenuItem(value: 'submitted', child: Text('Awaiting Review')),
      DropdownMenuItem(value: 'approved', child: Text('Completed')),
      DropdownMenuItem(value: 'rejected', child: Text('Changes Requested')),
      DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                hint: 'Search tasks by title, repo, or branch...',
                prefixIcon: Icons.search_rounded,
                onChanged: onSearchChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.filter_list_rounded, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: statusItems,
                onChanged: (val) => onStatusChanged(val ?? 'all'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: selectedRepo,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.code_rounded, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Repositories')),
                  ...repositories.map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (val) => onRepoChanged(val ?? 'all'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: AppColors.brandCyan),
              tooltip: sortAscending ? 'Sort Deadline: Earliest First' : 'Sort Deadline: Latest First',
              onPressed: onSortToggle,
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_text_field.dart';

enum TaskSortOption {
  deadline('Deadline'),
  priority('Priority'),
  status('Status');

  const TaskSortOption(this.label);
  final String label;
}

/// Header filter bar with search input and sort selection.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  final String searchQuery;
  final TaskSortOption selectedSort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 640;

    return isDesktop
        ? Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: AppSpacing.base),
              _buildSortDropdown(),
            ],
          )
        : Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: _buildSortDropdown(),
              ),
            ],
          );
  }

  Widget _buildSearchField() {
    return AppTextField(
      hint: 'Search tasks by title...',
      prefixIcon: Icons.search_rounded,
      onChanged: onSearchChanged,
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort_rounded, size: 16, color: AppColors.brandCyan),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<TaskSortOption>(
              value: selectedSort,
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              items: TaskSortOption.values
                  .map(
                    (opt) => DropdownMenuItem(
                      value: opt,
                      child: Text('Sort by: ${opt.label}'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) onSortChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

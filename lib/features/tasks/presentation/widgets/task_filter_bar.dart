import 'package:flutter/material.dart';
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

enum TaskStatusFilter {
  active('Active'),
  submitted('Under Review'),
  approved('Completed'),
  all('All');

  const TaskStatusFilter(this.label);
  final String label;
}

/// Header filter bar with search input, status filter, and segmented sort controls.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedSort,
    this.selectedStatus = TaskStatusFilter.active,
    required this.onSearchChanged,
    required this.onSortChanged,
    this.onStatusChanged,
  });

  final String searchQuery;
  final TaskSortOption selectedSort;
  final TaskStatusFilter selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskSortOption> onSortChanged;
  final ValueChanged<TaskStatusFilter>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 860;

    return isDesktop
        ? Row(
            children: [
              Expanded(child: _buildSearchField()),
              if (onStatusChanged != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _buildSegmentedStatus(),
              ],
              const SizedBox(width: AppSpacing.sm),
              _buildSegmentedSort(),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (onStatusChanged != null) _buildSegmentedStatus(),
                  _buildSegmentedSort(),
                ],
              ),
            ],
          );
  }

  Widget _buildSearchField() {
    return AppTextField(
      hint: 'Search tasks by title, repo, or description...',
      prefixIcon: Icons.search_rounded,
      onChanged: onSearchChanged,
    );
  }

  Widget _buildSegmentedStatus() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TaskStatusFilter.values.map((filter) {
          final isSelected = selectedStatus == filter;
          return GestureDetector(
            onTap: () => onStatusChanged?.call(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandCyan.withAlpha(45)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandCyan.withAlpha(90)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.brandCyan
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSegmentedSort() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TaskSortOption.values.map((opt) {
          final isSelected = selectedSort == opt;
          return GestureDetector(
            onTap: () => onSortChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandBlue.withAlpha(45)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandBlue.withAlpha(90)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Text(
                opt.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.brandBlue
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

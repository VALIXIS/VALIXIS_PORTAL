import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/models/sprint_models.dart';

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

/// Comprehensive filter bar supporting App Chips, Sprint Members, Day-by-Day schedule, and search/sort.
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedSort,
    this.selectedStatus = TaskStatusFilter.active,
    this.selectedApp = SprintApp.all,
    this.selectedMember = SprintMember.all,
    this.selectedDay = SprintDay.all,
    required this.onSearchChanged,
    required this.onSortChanged,
    this.onStatusChanged,
    this.onAppChanged,
    this.onMemberChanged,
    this.onDayChanged,
    this.showMemberFilter = true,
  });

  final String searchQuery;
  final TaskSortOption selectedSort;
  final TaskStatusFilter selectedStatus;
  final SprintApp selectedApp;
  final SprintMember selectedMember;
  final SprintDay selectedDay;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskSortOption> onSortChanged;
  final ValueChanged<TaskStatusFilter>? onStatusChanged;
  final ValueChanged<SprintApp>? onAppChanged;
  final ValueChanged<SprintMember>? onMemberChanged;
  final ValueChanged<SprintDay>? onDayChanged;
  final bool showMemberFilter;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 960;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Search Input + Status & Sort Segmented Controls
        if (isDesktop)
          Row(
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
        else
          Column(
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
          ),

        const SizedBox(height: AppSpacing.md),

        // Section 1: Multi-App Sprint Filter Chips
        if (onAppChanged != null) ...[
          _buildAppFilterChips(),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Section 2: Employee Workload Filter
        if (showMemberFilter && onMemberChanged != null)
          _buildMemberFilterRow(),
      ],
    );
  }

  Widget _buildSearchField() {
    return AppTextField(
      hint: 'Search tasks by title, repo, branch, or prompt keywords...',
      prefixIcon: Icons.search_rounded,
      onChanged: onSearchChanged,
    );
  }

  Widget _buildAppFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: SprintApp.values.map((app) {
          final isSelected = selectedApp == app;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onAppChanged?.call(app),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? app.color.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? app.color : AppColors.glassBorder,
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: app.color.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      app.icon,
                      size: 14,
                      color: isSelected ? app.color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      app.displayName,
                      style: TextStyle(
                        color: isSelected ? app.color : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemberFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: SprintMember.values.map((member) {
          final isSelected = selectedMember == member;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onMemberChanged?.call(member),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? member.color.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? member.color : AppColors.border,
                    width: isSelected ? 1.2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (member != SprintMember.all) ...[
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: member.color.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            member.initial,
                            style: TextStyle(
                              color: member.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
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
        }).toList(),
      ),
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
                    ? AppColors.brandCyan.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandCyan.withValues(alpha: 0.4)
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                    ? AppColors.brandBlue.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandBlue.withValues(alpha: 0.4)
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

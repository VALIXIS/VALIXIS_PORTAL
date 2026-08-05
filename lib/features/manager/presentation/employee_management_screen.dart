import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_text_field.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/components/glass_card.dart';
import 'providers/employee_management_provider.dart';

/// Screen displaying team employee management table with search, sort, and pagination.
class EmployeeManagementScreen extends ConsumerStatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  ConsumerState<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState
    extends ConsumerState<EmployeeManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  static const _pageSize = 8;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeManagementProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go(AppRoutes.managerDashboard),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Employee Management',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  AppTextField(
                    controller: _searchController,
                    hint: 'Search by employee name or email...',
                    prefixIcon: Icons.search_rounded,
                    onChanged: (val) => setState(() {
                      _searchQuery = val.toLowerCase().trim();
                      _currentPage = 0;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  employeesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Failed to load employees',
                      description: err.toString(),
                    ),
                    data: (employees) {
                      final filtered = employees.where((e) {
                        return e.employee.fullName.toLowerCase().contains(_searchQuery) ||
                            e.employee.email.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No Employees Found',
                          description: 'No team members match the search query.',
                        );
                      }

                      final totalPages = (filtered.length / _pageSize).ceil();
                      final paged = filtered
                          .skip(_currentPage * _pageSize)
                          .take(_pageSize)
                          .toList();

                      return Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  AppColors.surfaceElevated),
                              columns: const [
                                DataColumn(label: Text('Name', style: TextStyle(color: AppColors.textPrimary))),
                                DataColumn(label: Text('Email', style: TextStyle(color: AppColors.textPrimary))),
                                DataColumn(label: Text('Department', style: TextStyle(color: AppColors.textPrimary))),
                                DataColumn(label: Text('Assigned', style: TextStyle(color: AppColors.textPrimary))),
                                DataColumn(label: Text('Completed', style: TextStyle(color: AppColors.textPrimary))),
                                DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textPrimary))),
                              ],
                              rows: paged.map((e) {
                                return DataRow(cells: [
                                  DataCell(Text(e.employee.fullName, style: const TextStyle(color: AppColors.textPrimary))),
                                  DataCell(Text(e.employee.email, style: const TextStyle(color: AppColors.textMuted))),
                                  DataCell(Text(e.employee.department ?? 'Engineering', style: const TextStyle(color: AppColors.textSecondary))),
                                  DataCell(Text(e.tasksAssigned.toString(), style: const TextStyle(color: AppColors.textPrimary))),
                                  DataCell(Text(e.tasksCompleted.toString(), style: const TextStyle(color: AppColors.success))),
                                  DataCell(Text(e.status, style: TextStyle(color: e.status == 'Busy' ? AppColors.warning : AppColors.success))),
                                ]);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Page ${_currentPage + 1} of $totalPages',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left_rounded),
                                    onPressed: _currentPage > 0
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right_rounded),
                                    onPressed: (_currentPage + 1) < totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
import 'widgets/employee_card_view.dart';
import 'widgets/employee_table_view.dart';

/// Screen displaying team employee management directory with search, sort, and pagination.
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 700;

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
                const SizedBox(width: AppSpacing.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Enterprise Workforce Directory',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Audit employee task workloads, department assignments, and availability',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassCard(
              showGlow: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  AppTextField(
                    controller: _searchController,
                    hint: 'Search by employee name or email address...',
                    prefixIcon: Icons.search_rounded,
                    onChanged: (val) => setState(() {
                      _searchQuery = val.toLowerCase().trim();
                      _currentPage = 0;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  employeesAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl4),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Failed to load employees',
                      description: err.toString(),
                    ),
                    data: (employees) {
                      final filtered = employees.where((e) {
                        return e.employee.fullName
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            e.employee.email
                                .toLowerCase()
                                .contains(_searchQuery);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No Employees Found',
                          description:
                              'No team members match your current search query.',
                        );
                      }

                      final totalPages = (filtered.length / _pageSize).ceil();
                      final paged = filtered
                          .skip(_currentPage * _pageSize)
                          .take(_pageSize)
                          .toList();

                      return Column(
                        children: [
                          isDesktop
                              ? EmployeeTableView(employees: paged)
                              : EmployeeCardView(employees: paged),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing Page ${_currentPage + 1} of $totalPages (${filtered.length} total)',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left_rounded),
                                    color: AppColors.brandCyan,
                                    onPressed: _currentPage > 0
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.chevron_right_rounded),
                                    color: AppColors.brandCyan,
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

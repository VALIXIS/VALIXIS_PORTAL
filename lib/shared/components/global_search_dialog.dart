import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/manager/presentation/providers/employee_management_provider.dart';
import 'glass_card.dart';

/// Global Search Dialog modal (Ctrl/Cmd + K) searching across tasks, employees, and submissions.
class GlobalSearchDialog extends ConsumerStatefulWidget {
  const GlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const GlobalSearchDialog(),
    );
  }

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';
  final List<String> _recentSearches = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardData = ref.watch(dashboardProvider).valueOrNull;
    final employeesData = ref.watch(employeeManagementProvider).valueOrNull ?? [];
    final tasks = dashboardData?.recentTasks ?? [];

    final filteredTasks = _query.isEmpty
        ? []
        : tasks.where((t) =>
            t.title.toLowerCase().contains(_query.toLowerCase()) ||
            (t.description?.toLowerCase().contains(_query.toLowerCase()) ?? false)).toList();

    final filteredEmployees = _query.isEmpty
        ? []
        : employeesData.where((e) =>
            e.employee.fullName.toLowerCase().contains(_query.toLowerCase()) ||
            e.employee.email.toLowerCase().contains(_query.toLowerCase())).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 550),
        child: GlassCard(
          showGlow: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search tasks, employees, or submissions (Ctrl+K)...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandCyan),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                ),
                onChanged: (val) => setState(() => _query = val.trim()),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_query.isEmpty) ...[
                if (_recentSearches.isNotEmpty) ...[
                  const Text('Recent Searches', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    children: _recentSearches.map((s) {
                      return ActionChip(
                        label: Text(s, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                        backgroundColor: AppColors.surfaceElevated,
                        onPressed: () {
                          _searchController.text = s;
                          setState(() => _query = s);
                        },
                      );
                    }).toList(),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Type a search term to find tasks, employees, or submissions',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                Expanded(
                  child: ListView(
                    children: [
                      if (filteredTasks.isNotEmpty) ...[
                        const Text('Tasks', style: TextStyle(color: AppColors.brandCyan, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        ...filteredTasks.map((t) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.task_alt_rounded, color: AppColors.brandCyan, size: 18),
                          title: Text(t.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          subtitle: Text(t.status.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          onTap: () {
                            Navigator.pop(context);
                            context.go('${AppRoutes.tasks}/${t.id}');
                          },
                        )),
                      ],
                      if (filteredEmployees.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Text('Employees', style: TextStyle(color: AppColors.brandPurple, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        ...filteredEmployees.map((e) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.person_rounded, color: AppColors.brandPurple, size: 18),
                          title: Text(e.employee.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          subtitle: Text(e.employee.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          onTap: () {
                            Navigator.pop(context);
                            context.go(AppRoutes.managerEmployees);
                          },
                        )),
                      ],
                      if (filteredTasks.isEmpty && filteredEmployees.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('No results match your search query.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

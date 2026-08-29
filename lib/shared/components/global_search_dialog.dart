import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/manager/presentation/providers/employee_management_provider.dart';
import 'export_center_dialog.dart';
import 'glass_card.dart';

/// Global Command Palette & Search Dialog modal (Ctrl/Cmd + K) for instant navigation & search across tasks, employees, and quick actions.
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

    final q = _query.toLowerCase();

    final filteredTasks = _query.isEmpty
        ? []
        : tasks.where((t) =>
            t.title.toLowerCase().contains(q) ||
            (t.githubRepo?.toLowerCase().contains(q) ?? false) ||
            (t.branchName?.toLowerCase().contains(q) ?? false) ||
            (t.description?.toLowerCase().contains(q) ?? false)).toList();

    final filteredEmployees = _query.isEmpty
        ? []
        : employeesData.where((e) =>
            e.employee.fullName.toLowerCase().contains(q) ||
            e.employee.email.toLowerCase().contains(q) ||
            (e.employee.department?.toLowerCase().contains(q) ?? false)).toList();

    final commandActions = [
      _CommandAction(
        title: 'Create New Task',
        subtitle: 'Dispatch a new engineering task specification',
        icon: Icons.add_task_rounded,
        color: AppColors.brandCyan,
        onTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.managerCreateTask);
        },
      ),
      _CommandAction(
        title: 'Manager Tasks Overview',
        subtitle: 'View, filter, sort, reassign, or delete tasks',
        icon: Icons.assignment_rounded,
        color: AppColors.brandBlue,
        onTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.managerTasks);
        },
      ),
      _CommandAction(
        title: 'Review Submissions',
        subtitle: 'Audit PR links and evaluate developer submissions',
        icon: Icons.rate_review_rounded,
        color: AppColors.brandPurple,
        onTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.managerReviews);
        },
      ),
      _CommandAction(
        title: 'Employee Workload Directory',
        subtitle: 'View active employee roster and availability',
        icon: Icons.people_alt_rounded,
        color: AppColors.success,
        onTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.managerEmployees);
        },
      ),
      _CommandAction(
        title: 'Security Audit Logs',
        subtitle: 'Inspect login events, durations, and system activity',
        icon: Icons.fact_check_rounded,
        color: AppColors.warning,
        onTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.managerAuditLogs);
        },
      ),
      _CommandAction(
        title: 'Direct WhatsApp Task Dispatcher',
        subtitle: 'Send instant automated task alerts to WhatsApp',
        icon: Icons.chat_bubble_rounded,
        color: AppColors.success,
        onTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.managerWhatsApp);
        },
      ),
      _CommandAction(
        title: 'Export System CSV Reports',
        subtitle: 'Download task specifications, employee roster, or dashboard summary',
        icon: Icons.download_rounded,
        color: AppColors.brandCyan,
        onTap: () {
          Navigator.pop(context);
          ExportCenterDialog.show(context);
        },
      ),
    ];

    final filteredCommands = _query.isEmpty
        ? commandActions
        : commandActions
            .where((c) =>
                c.title.toLowerCase().contains(q) ||
                c.subtitle.toLowerCase().contains(q))
            .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 580),
        child: GlassCard(
          showGlow: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Type a command or search tasks, employees, repos (Cmd+K)...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandCyan),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Text('ESC', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
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
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (_query.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'QUICK COMMANDS',
                          style: TextStyle(color: AppColors.brandCyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                      ...commandActions.map((cmd) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cmd.color.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cmd.icon, color: cmd.color, size: 16),
                            ),
                            title: Text(cmd.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                            subtitle: Text(cmd.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 12),
                            onTap: cmd.onTap,
                          )),
                    ] else ...[
                      if (filteredCommands.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'COMMAND ACTIONS',
                            style: TextStyle(color: AppColors.brandCyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ),
                        ...filteredCommands.map((cmd) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              leading: Icon(cmd.icon, color: cmd.color, size: 18),
                              title: Text(cmd.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                              subtitle: Text(cmd.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              onTap: cmd.onTap,
                            )),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (filteredTasks.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'TASKS & REPOSITORIES',
                            style: TextStyle(color: AppColors.brandBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ),
                        ...filteredTasks.map((t) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              leading: const Icon(Icons.task_alt_rounded, color: AppColors.brandBlue, size: 18),
                              title: Text(t.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                              subtitle: Text('${t.githubRepo ?? 'VALIXIS_PORTAL'} • ${t.priority.label}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/tasks/${t.id}');
                              },
                            )),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (filteredEmployees.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'EMPLOYEES & DIRECTORY',
                            style: TextStyle(color: AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ),
                        ...filteredEmployees.map((e) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              leading: const Icon(Icons.person_rounded, color: AppColors.brandPurple, size: 18),
                              title: Text(e.employee.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                              subtitle: Text('${e.employee.email} • ${e.employee.department ?? 'Engineering'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              onTap: () {
                                Navigator.pop(context);
                                context.go(AppRoutes.managerEmployees);
                              },
                            )),
                      ],
                      if (filteredCommands.isEmpty && filteredTasks.isEmpty && filteredEmployees.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('No command actions, tasks, or employees match your search query.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandAction {
  const _CommandAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

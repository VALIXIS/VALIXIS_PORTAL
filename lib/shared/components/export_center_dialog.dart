import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/network/supabase_client_provider.dart';
import '../../core/utils/csv_downloader.dart';

/// Modal dialog for exporting system reports directly to downloadable CSV files.
class ExportCenterDialog extends ConsumerStatefulWidget {
  const ExportCenterDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ExportCenterDialog(),
    );
  }

  @override
  ConsumerState<ExportCenterDialog> createState() => _ExportCenterDialogState();
}

class _ExportCenterDialogState extends ConsumerState<ExportCenterDialog> {
  bool _isExporting = false;

  Future<void> _exportData(String reportType) async {
    setState(() => _isExporting = true);

    try {
      final client = ref.read(supabaseClientProvider);
      String csvContent = '';
      String fileName = '';
      final todayStr = DateTime.now().toIso8601String().split('T').first;

      if (reportType == 'Task Specifications') {
        fileName = 'VALIXIS_Task_Specifications_$todayStr.csv';
        final response = await client
            .from('tasks')
            .select('*, task_assignments(*, employees(*))')
            .order('created_at', ascending: false);

        final rows = response as List<dynamic>;
        final buffer = StringBuffer();
        buffer.writeln('Task ID,Title,Priority,Status,Assignee Name,Assignee Email,Deadline,GitHub Repo,Branch,Created At');

        for (final row in rows) {
          final id = _escapeCsv(row['id']?.toString());
          final title = _escapeCsv(row['title']?.toString());
          final priority = _escapeCsv(row['priority']?.toString());
          final status = _escapeCsv(row['status']?.toString());

          final assignments = row['task_assignments'] as List<dynamic>?;
          String assigneeName = 'Unassigned';
          String assigneeEmail = '';
          if (assignments != null && assignments.isNotEmpty) {
            final emp = assignments.first['employees'] as Map<String, dynamic>?;
            if (emp != null) {
              assigneeName = emp['name']?.toString() ?? 'Unassigned';
              assigneeEmail = emp['email']?.toString() ?? '';
            }
          }

          final deadline = _escapeCsv(row['deadline']?.toString());
          final repo = _escapeCsv(row['github_repository']?.toString());
          final branch = _escapeCsv(row['branch_name']?.toString());
          final createdAt = _escapeCsv(row['created_at']?.toString());

          buffer.writeln('$id,$title,$priority,$status,${_escapeCsv(assigneeName)},${_escapeCsv(assigneeEmail)},$deadline,$repo,$branch,$createdAt');
        }
        csvContent = buffer.toString();
      } else if (reportType == 'Workforce Directory') {
        fileName = 'VALIXIS_Workforce_Directory_$todayStr.csv';
        final response = await client
            .from('employees')
            .select('*')
            .order('name', ascending: true);

        final rows = response as List<dynamic>;
        final buffer = StringBuffer();
        buffer.writeln('Employee ID,Name,Email,Role,Department,Phone,Created At');

        for (final row in rows) {
          final id = _escapeCsv(row['id']?.toString());
          final name = _escapeCsv(row['name']?.toString());
          final email = _escapeCsv(row['email']?.toString());
          final role = _escapeCsv(row['role']?.toString());
          final dept = _escapeCsv(row['department']?.toString());
          final phone = _escapeCsv(row['phone']?.toString());
          final createdAt = _escapeCsv(row['created_at']?.toString());

          buffer.writeln('$id,$name,$email,$role,$dept,$phone,$createdAt');
        }
        csvContent = buffer.toString();
      } else {
        fileName = 'VALIXIS_Executive_Dashboard_$todayStr.csv';
        final tasksRes = await client.from('tasks').select('status');
        final empRes = await client.from('employees').select('role');

        final tasks = tasksRes as List<dynamic>;
        final emps = empRes as List<dynamic>;

        final totalTasks = tasks.length;
        final completedTasks = tasks.where((t) => (t['status']?.toString().toLowerCase() ?? '').contains('completed')).length;
        final pendingTasks = totalTasks - completedTasks;
        final totalEmps = emps.length;
        final managersCount = emps.where((e) => (e['role']?.toString().toLowerCase() ?? '').contains('manager')).length;
        final employeesCount = totalEmps - managersCount;

        final buffer = StringBuffer();
        buffer.writeln('Executive Metric,Value');
        buffer.writeln('Report Date,$todayStr');
        buffer.writeln('Total Registered Tasks,$totalTasks');
        buffer.writeln('Completed Tasks,$completedTasks');
        buffer.writeln('Pending / Active Tasks,$pendingTasks');
        buffer.writeln('Total Team Members,$totalEmps');
        buffer.writeln('Managers Count,$managersCount');
        buffer.writeln('Engineers Count,$employeesCount');

        csvContent = buffer.toString();
      }

      downloadCsv(fileName, csvContent);

      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$reportType exported & downloaded as CSV!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _escapeCsv(String? input) {
    if (input == null || input.isEmpty) return '""';
    final escaped = input.replaceAll('"', '""');
    return '"$escaped"';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.brandCyan.withAlpha(80), width: 1.5),
      ),
      title: Row(
        children: const [
          Icon(Icons.download_rounded, color: AppColors.brandCyan, size: 22),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Export Center',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select report data format to export to CSV:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.md),
          _ExportTile(
            title: 'Task Specifications & Status',
            subtitle: 'Includes task IDs, titles, priorities, and deadlines',
            icon: Icons.assignment_rounded,
            onTap: _isExporting ? null : () => _exportData('Task Specifications'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ExportTile(
            title: 'Workforce & Employee Directory',
            subtitle: 'Includes employee names, roles, departments, and workloads',
            icon: Icons.people_rounded,
            onTap: _isExporting ? null : () => _exportData('Workforce Directory'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ExportTile(
            title: 'Executive Dashboard Summary',
            subtitle: 'Includes overall workload metrics and PR review counts',
            icon: Icons.query_stats_rounded,
            onTap: _isExporting ? null : () => _exportData('Executive Dashboard'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandCyan.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.brandCyan, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.file_download_outlined, color: AppColors.brandCyan, size: 18),
          ],
        ),
      ),
    );
  }
}

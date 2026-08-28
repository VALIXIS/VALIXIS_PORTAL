import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/network/supabase_client_provider.dart';
import '../../core/utils/csv_downloader.dart';

/// Modal dialog for exporting system reports directly to downloadable CSV files with clean human-readable formatting.
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

        final tasksRes = await client.from('tasks').select('*').order('created_at', ascending: false);
        final assignRes = await client.from('task_assignments').select('*');
        final empRes = await client.from('employees').select('id, name, email');
        final subRes = await client.from('submissions').select('*');

        final tasksList = tasksRes as List<dynamic>;
        final assignList = (assignRes as List<dynamic>).cast<Map<String, dynamic>>();
        final empList = (empRes as List<dynamic>).cast<Map<String, dynamic>>();
        final subList = (subRes as List<dynamic>).cast<Map<String, dynamic>>();

        final empMap = <String, Map<String, dynamic>>{};
        for (final emp in empList) {
          empMap[emp['id'].toString()] = emp;
        }

        final assignMap = <String, Map<String, dynamic>>{};
        for (final ass in assignList) {
          assignMap[ass['task_id'].toString()] = ass;
        }

        final subMap = <String, Map<String, dynamic>>{};
        for (final sub in subList) {
          final assId = sub['assignment_id']?.toString();
          if (assId != null) {
            subMap[assId] = sub;
          }
        }

        final buffer = StringBuffer();
        buffer.writeln('Task Title,Repository,Branch,Priority,Status,Assigned Engineer,Engineer Email,Deadline,PR Submitted,PR Link,Objective,Task ID,Created Date');

        for (final task in tasksList) {
          final taskId = task['id']?.toString() ?? '';
          final title = _escapeCsv(task['title']?.toString());
          final repo = _escapeCsv(task['github_repository']?.toString() ?? 'VALIXIS_PORTAL');
          final branch = _escapeCsv(task['branch_name']?.toString() ?? 'main');
          final priority = _escapeCsv(task['priority']?.toString() ?? 'Medium');

          final assignment = assignMap[taskId];
          String status = 'Unassigned';
          String engineerName = 'Unassigned';
          String engineerEmail = 'N/A';
          String prSubmitted = 'No';
          String prUrl = 'N/A';

          if (assignment != null) {
            final rawStatus = assignment['status']?.toString() ?? 'assigned';
            status = _formatStatusLabel(rawStatus);

            final empId = assignment['employee_id']?.toString();
            if (empId != null && empMap.containsKey(empId)) {
              engineerName = empMap[empId]!['name']?.toString() ?? 'Assigned Engineer';
              engineerEmail = empMap[empId]!['email']?.toString() ?? '';
            }

            final assId = assignment['id']?.toString();
            final submission = assId != null ? subMap[assId] : null;
            final rawPr = assignment['pr_url']?.toString() ?? submission?['github_pr_url']?.toString();
            if (rawPr != null && rawPr.isNotEmpty) {
              prSubmitted = 'Yes';
              prUrl = rawPr;
            }
          }

          final deadline = _escapeCsv(task['deadline']?.toString() != null ? task['deadline'].toString().split('T').first : 'N/A');
          final objective = _escapeCsv(task['objective']?.toString() ?? task['description']?.toString() ?? '');
          final createdAt = _escapeCsv(task['created_at']?.toString() != null ? task['created_at'].toString().split('T').first : '');

          buffer.writeln('$title,$repo,$branch,$priority,${_escapeCsv(status)},${_escapeCsv(engineerName)},${_escapeCsv(engineerEmail)},$deadline,${_escapeCsv(prSubmitted)},${_escapeCsv(prUrl)},$objective,${_escapeCsv(taskId)},$createdAt');
        }
        csvContent = buffer.toString();
      } else if (reportType == 'Workforce Directory') {
        fileName = 'VALIXIS_Workforce_Directory_$todayStr.csv';

        final empRes = await client.from('employees').select('*').order('name', ascending: true);
        final assignRes = await client.from('task_assignments').select('*');

        final empList = empRes as List<dynamic>;
        final assignList = (assignRes as List<dynamic>).cast<Map<String, dynamic>>();

        final assignedCounts = <String, int>{};
        final completedCounts = <String, int>{};

        for (final ass in assignList) {
          final empId = ass['employee_id']?.toString();
          if (empId != null) {
            final st = (ass['status']?.toString() ?? '').toLowerCase();
            if (st == 'approved' || st == 'completed') {
              completedCounts[empId] = (completedCounts[empId] ?? 0) + 1;
            } else {
              assignedCounts[empId] = (assignedCounts[empId] ?? 0) + 1;
            }
          }
        }

        final buffer = StringBuffer();
        buffer.writeln('Engineer Name,Email Address,Role,Department,Phone Number,Assigned Tasks Count,Completed Tasks Count,Workload Status,Employee ID,Joined Date');

        for (final emp in empList) {
          final empId = emp['id']?.toString() ?? '';
          final name = _escapeCsv(emp['name']?.toString() ?? '');
          final email = _escapeCsv(emp['email']?.toString() ?? '');
          final role = _escapeCsv(_capitalize(emp['role']?.toString() ?? 'Engineering'));
          final dept = _escapeCsv(emp['department']?.toString() ?? 'Engineering');
          final phone = _escapeCsv(emp['phone']?.toString() ?? 'N/A');

          final assigned = assignedCounts[empId] ?? 0;
          final completed = completedCounts[empId] ?? 0;
          final workloadStatus = assigned >= 3 ? 'Busy' : 'Available';

          final createdAt = _escapeCsv(emp['created_at']?.toString() != null ? emp['created_at'].toString().split('T').first : '');

          buffer.writeln('$name,$email,$role,$dept,$phone,$assigned,$completed,${_escapeCsv(workloadStatus)},${_escapeCsv(empId)},$createdAt');
        }
        csvContent = buffer.toString();
      } else {
        fileName = 'VALIXIS_Executive_Dashboard_$todayStr.csv';

        final tasksRes = await client.from('tasks').select('id');
        final assignRes = await client.from('task_assignments').select('status, pr_url');
        final empRes = await client.from('employees').select('role');
        final subRes = await client.from('submissions').select('id');

        final totalTasks = (tasksRes as List<dynamic>).length;
        final assignments = (assignRes as List<dynamic>).cast<Map<String, dynamic>>();
        final emps = (empRes as List<dynamic>).cast<Map<String, dynamic>>();
        final submissionsCount = (subRes as List<dynamic>).length;

        int completedCount = 0;
        int inProgressCount = 0;
        int awaitingReviewCount = 0;

        for (final ass in assignments) {
          final st = (ass['status']?.toString() ?? '').toLowerCase();
          if (st == 'approved' || st == 'completed') {
            completedCount++;
          } else if (st == 'submitted') {
            awaitingReviewCount++;
          } else {
            inProgressCount++;
          }
        }

        final totalTeam = emps.length;
        final managersCount = emps.where((e) => (e['role']?.toString().toLowerCase() ?? '').contains('manager')).length;
        final engineersCount = totalTeam - managersCount;

        final buffer = StringBuffer();
        buffer.writeln('Executive Metric,Count / Value,Metric Description');
        buffer.writeln('Report Export Date,$todayStr,Date of summary generation');
        buffer.writeln('Total Engineering Tasks,$totalTasks,Total task specifications created');
        buffer.writeln('Active / In Progress Tasks,$inProgressCount,Tasks currently assigned or in progress');
        buffer.writeln('Completed Tasks,$completedCount,Tasks verified and approved');
        buffer.writeln('Awaiting PR Review Tasks,$awaitingReviewCount,Tasks submitted by engineers waiting for review');
        buffer.writeln('Total PR Submissions,$submissionsCount,Total code submissions recorded');
        buffer.writeln('Total Team Members,$totalTeam,Active personnel in directory');
        buffer.writeln('Engineering Managers,$managersCount,Management role accounts');
        buffer.writeln('Software Engineers,$engineersCount,Engineering role accounts');

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

  String _formatStatusLabel(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'submitted':
        return 'Awaiting Review';
      case 'approved':
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Changes Requested';
      default:
        return _capitalize(raw);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
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

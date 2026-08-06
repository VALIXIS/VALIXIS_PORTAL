import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuditLogItem {
  const AuditLogItem({
    required this.id,
    required this.actor,
    required this.action,
    required this.category,
    required this.timestamp,
    required this.ipAddress,
    required this.status,
  });

  final String id;
  final String actor;
  final String action;
  final String category;
  final DateTime timestamp;
  final String ipAddress;
  final String status;
}

/// Data table component for Manager Audit Logs.
class AuditLogsTable extends StatelessWidget {
  const AuditLogsTable({super.key, required this.logs});

  final List<AuditLogItem> logs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Timestamp', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Actor', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Action Event', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Category', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700))),
          DataColumn(label: Text('IP Address', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700))),
        ],
        rows: logs.map((log) {
          return DataRow(cells: [
            DataCell(Text('${log.timestamp.hour}:${log.timestamp.minute}:${log.timestamp.second}', style: const TextStyle(color: AppColors.textMuted))),
            DataCell(Text(log.actor, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
            DataCell(Text(log.action, style: const TextStyle(color: AppColors.brandCyan, fontWeight: FontWeight.w600))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(log.category, style: const TextStyle(color: AppColors.brandBlue, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
            DataCell(Text(log.ipAddress, style: const TextStyle(color: AppColors.textMuted))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(log.status, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

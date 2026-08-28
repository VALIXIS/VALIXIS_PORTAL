import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuditLogItem {
  const AuditLogItem({
    required this.id,
    required this.actor,
    required this.action,
    required this.category,
    required this.timestamp,
    this.lastSeen,
    required this.ipAddress,
    required this.status,
    this.details,
  });

  final String id;
  final String actor;
  final String action;
  final String category;
  final DateTime timestamp;
  final DateTime? lastSeen;
  final String ipAddress;
  final String status;
  final String? details;
}

/// Data table component for Manager Audit Logs supporting interactive column header sorting.
class AuditLogsTable extends StatefulWidget {
  const AuditLogsTable({super.key, required this.logs});

  final List<AuditLogItem> logs;

  @override
  State<AuditLogsTable> createState() => _AuditLogsTableState();
}

class _AuditLogsTableState extends State<AuditLogsTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = false;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $month ${dt.year} ${hour.toString().padLeft(2, '0')}:$minuteStr $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final sortedList = List<AuditLogItem>.from(widget.logs);
    sortedList.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.timestamp.compareTo(b.timestamp);
          break;
        case 1:
          final aLast = a.lastSeen ?? a.timestamp;
          final bLast = b.lastSeen ?? b.timestamp;
          cmp = aLast.compareTo(bLast);
          break;
        case 2:
          cmp = a.actor.toLowerCase().compareTo(b.actor.toLowerCase());
          break;
        case 3:
          cmp = a.action.toLowerCase().compareTo(b.action.toLowerCase());
          break;
        case 4:
          cmp = a.category.toLowerCase().compareTo(b.category.toLowerCase());
          break;
        case 5:
          cmp = a.ipAddress.compareTo(b.ipAddress);
          break;
        case 6:
          cmp = a.status.compareTo(b.status);
          break;
        case 7:
          cmp = (a.details ?? '').compareTo(b.details ?? '');
          break;
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
        dataRowMaxHeight: 56,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: const Text('Timestamp', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Last Active', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Actor', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Action Event', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Category', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('IP Address', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
        ],
        rows: sortedList.map((log) {
          return DataRow(cells: [
            DataCell(Text(_formatDateTime(log.timestamp), style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataCell(Text(log.lastSeen != null ? _formatDateTime(log.lastSeen!) : _formatDateTime(log.timestamp), style: const TextStyle(color: AppColors.brandCyan, fontSize: 12, fontWeight: FontWeight.w600))),
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
            DataCell(Text(log.details ?? 'N/A', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          ]);
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/components/glass_card.dart';

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
    return '${dt.day} $month ${dt.year} • ${hour.toString().padLeft(2, '0')}:$minuteStr $amPm';
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

    return GlassCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
                  headingRowHeight: 46,
                  dataRowMaxHeight: 56,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columnSpacing: 20,
                  horizontalMargin: 20,
                  columns: [
                    DataColumn(
                      label: Text(
                        'TIMESTAMP',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'LAST SEEN',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'ACTOR',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'EVENT ACTION',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'CATEGORY',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'IP ADDRESS',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'STATUS',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                    DataColumn(
                      label: Text(
                        'DETAILS',
                        style: AppTypography.telemetryHeader(size: 10, color: AppColors.textMuted, spacing: 0.8),
                      ),
                      onSort: _onSort,
                    ),
                  ],
                  rows: sortedList.map((log) {
                    final isLineActive = log.status.contains('Active');
                    final isLoggedOut = log.status.contains('Logged Out') || log.status.contains('Ended');
                    final statusColor = isLineActive
                        ? AppColors.success
                        : (isLoggedOut ? AppColors.textMuted : AppColors.error);

                    return DataRow(cells: [
                      DataCell(Text(
                        _formatDateTime(log.timestamp),
                        style: AppTypography.mono(size: 11, color: AppColors.textMuted),
                      )),
                      DataCell(Text(
                        log.lastSeen != null ? _formatDateTime(log.lastSeen!) : _formatDateTime(log.timestamp),
                        style: AppTypography.mono(size: 11, color: AppColors.brandCyan),
                      )),
                      DataCell(Text(
                        log.actor,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                      )),
                      DataCell(Text(
                        log.action,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.brandCyan, fontWeight: FontWeight.w600, fontSize: 13),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brandBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            log.category.toUpperCase(),
                            style: AppTypography.telemetryHeader(size: 9, color: AppColors.brandBlue, spacing: 0.5),
                          ),
                        ),
                      ),
                      DataCell(Text(
                        log.ipAddress,
                        style: AppTypography.mono(size: 11, color: AppColors.textSecondary),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                log.status.toUpperCase(),
                                style: AppTypography.telemetryHeader(size: 9, color: statusColor, spacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(
                        log.details ?? '—',
                        style: AppTypography.mono(size: 11, color: AppColors.textMuted),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


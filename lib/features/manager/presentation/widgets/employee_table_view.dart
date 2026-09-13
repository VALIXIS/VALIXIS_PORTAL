import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/employee_management_repository.dart';

/// Desktop data table component for employee directory supporting interactive column header sorting.
class EmployeeTableView extends StatefulWidget {
  const EmployeeTableView({super.key, required this.employees});

  final List<EmployeeManagementData> employees;

  @override
  State<EmployeeTableView> createState() => _EmployeeTableViewState();
}

class _EmployeeTableViewState extends State<EmployeeTableView> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedList = List<EmployeeManagementData>.from(widget.employees);
    sortedList.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.employee.fullName.toLowerCase().compareTo(b.employee.fullName.toLowerCase());
          break;
        case 1:
          cmp = a.employee.email.toLowerCase().compareTo(b.employee.email.toLowerCase());
          break;
        case 2:
          cmp = (a.employee.department ?? 'Engineering').toLowerCase().compareTo((b.employee.department ?? 'Engineering').toLowerCase());
          break;
        case 3:
          cmp = a.tasksAssigned.compareTo(b.tasksAssigned);
          break;
        case 4:
          cmp = a.tasksCompleted.compareTo(b.tasksCompleted);
          break;
        case 5:
          cmp = a.status.compareTo(b.status);
          break;
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return LayoutBuilder(
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
                dataRowMaxHeight: 60,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columnSpacing: 24,
                horizontalMargin: 20,
                columns: [
                  DataColumn(
                    label: Text(
                      'EMPLOYEE',
                      style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                    ),
                    onSort: _onSort,
                  ),
                  DataColumn(
                    label: Text(
                      'WORK EMAIL',
                      style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                    ),
                    onSort: _onSort,
                  ),
                  DataColumn(
                    label: Text(
                      'DEPARTMENT',
                      style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                    ),
                    onSort: _onSort,
                  ),
                  DataColumn(
                    label: Text(
                      'ASSIGNED',
                      style: AppTypography.telemetryHeader(size: 10, color: AppColors.textSecondary, spacing: 0.8),
                    ),
                    onSort: _onSort,
                  ),
                  DataColumn(
                    label: Text(
                      'COMPLETED',
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
                ],
                rows: sortedList.map((e) {
                  final isBusy = e.status == 'Busy';
                  final statusColor = isBusy ? AppColors.warning : AppColors.success;
                  final initials = e.employee.fullName.isNotEmpty ? e.employee.fullName[0].toUpperCase() : 'E';

                  return DataRow(cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.brandBlue.withValues(alpha: 0.25),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: AppColors.brandCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.surfaceElevated, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            e.employee.fullName,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(
                      e.employee.email,
                      style: AppTypography.mono(size: 12, color: AppColors.textSecondary),
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
                          (e.employee.department ?? 'Engineering').toUpperCase(),
                          style: AppTypography.telemetryHeader(size: 9, color: AppColors.brandCyan, spacing: 0.5),
                        ),
                      ),
                    ),
                    DataCell(Text(
                      '${e.tasksAssigned}',
                      style: AppTypography.mono(size: 13, color: AppColors.textPrimary, weight: FontWeight.w700),
                    )),
                    DataCell(Text(
                      '${e.tasksCompleted}',
                      style: AppTypography.mono(size: 13, color: AppColors.success, weight: FontWeight.w700),
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
                              e.status.toUpperCase(),
                              style: AppTypography.telemetryHeader(size: 9, color: statusColor, spacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

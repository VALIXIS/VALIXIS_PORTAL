import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
        dataRowMaxHeight: 64,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: const Text('Employee', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Email', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Department', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Assigned', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Completed', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('Availability', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
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
                        backgroundColor: AppColors.brandBlue.withAlpha(40),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.brandCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          height: 8,
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(Text(e.employee.email, style: const TextStyle(color: AppColors.textMuted))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  e.employee.department ?? 'Engineering',
                  style: const TextStyle(color: AppColors.brandCyan, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataCell(Text('${e.tasksAssigned}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
            DataCell(Text('${e.tasksCompleted}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Text(
                  e.status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

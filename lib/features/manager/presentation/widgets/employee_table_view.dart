import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/employee_management_repository.dart';

/// Desktop data table component for employee directory.
class EmployeeTableView extends StatelessWidget {
  const EmployeeTableView({super.key, required this.employees});

  final List<EmployeeManagementData> employees;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated),
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(
              label: Text('Employee',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700))),
          DataColumn(
              label: Text('Email',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700))),
          DataColumn(
              label: Text('Department',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700))),
          DataColumn(
              label: Text('Assigned',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700))),
          DataColumn(
              label: Text('Completed',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700))),
          DataColumn(
              label: Text('Availability',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700))),
        ],
        rows: employees.map((e) {
          final isBusy = e.status == 'Busy';
          final statusColor = isBusy ? AppColors.warning : AppColors.success;
          final initials = e.employee.fullName.isNotEmpty
              ? e.employee.fullName[0].toUpperCase()
              : 'E';

          return DataRow(cells: [
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
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
            DataCell(Text(e.employee.email,
                style: const TextStyle(color: AppColors.textMuted))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  e.employee.department ?? 'Engineering',
                  style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataCell(Text('${e.tasksAssigned}',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600))),
            DataCell(Text('${e.tasksCompleted}',
                style: const TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w600))),
            DataCell(
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Text(
                  e.status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

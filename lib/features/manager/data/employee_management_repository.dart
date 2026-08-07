import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/employee.dart';
import '../../employee/data/mappers/employee_mapper.dart';

class EmployeeManagementData {
  const EmployeeManagementData({
    required this.employee,
    required this.tasksAssigned,
    required this.tasksCompleted,
    required this.status,
  });

  final Employee employee;
  final int tasksAssigned;
  final int tasksCompleted;
  final String status;
}

/// Repository for employee management data querying.
class EmployeeManagementRepository {
  EmployeeManagementRepository(this._client);

  final SupabaseClient _client;

  /// Fetches employees from Supabase excluding only manager/admin roles.
  Future<List<EmployeeManagementData>> getEmployeeList() async {
    final response = await _client.from('employees').select();
    final list = response as List<dynamic>;

    final employeeMap = <String, Employee>{};
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final emp = EmployeeMapper.fromJson(item);
        if (emp.id.isEmpty) continue;

        final role = emp.role?.toLowerCase().trim();
        if (role != null && role.isNotEmpty) {
          if (role.contains('manager') ||
              role.contains('admin') ||
              role.contains('supervisor')) {
            continue;
          }
        }

        employeeMap[emp.id] = emp;
      }
    }

    final employees = employeeMap.values.toList();

    List<dynamic> assignments = [];
    try {
      final assignmentsResponse =
          await _client.from('task_assignments').select();
      assignments = (assignmentsResponse as List<dynamic>?) ?? [];
    } catch (_) {}

    return employees.map((emp) {
      final empAssignments = assignments.where(
          (a) => a['employee_id']?.toString() == emp.id || a['user_id']?.toString() == emp.id);

      final assignedCount = empAssignments.length;
      final completedCount = empAssignments
          .where((a) => a['status'] == 'approved' || a['status'] == 'completed')
          .length;

      final isBusy = empAssignments.any((a) => a['status'] == 'in_progress');

      return EmployeeManagementData(
        employee: emp,
        tasksAssigned: assignedCount,
        tasksCompleted: completedCount,
        status: isBusy ? 'Busy' : 'Available',
      );
    }).toList();
  }
}

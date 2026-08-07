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

  /// Fetches employees excluding manager/admin roles.
  /// Bypasses client RLS policy `(auth.uid() = auth_id)` via manager Edge Function.
  Future<List<EmployeeManagementData>> getEmployeeList() async {
    List<dynamic> list = [];

    try {
      final response = await _client.functions.invoke('manager-dashboard');
      if (response.status < 400 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['employees'] ??
            data['employee_list'] ??
            data['team'] ??
            data['workforce'];
        if (raw is List<dynamic> && raw.isNotEmpty) {
          list = raw;
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      try {
        final response = await _client.from('employees').select();
        list = response as List<dynamic>;
      } catch (_) {}
    }

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

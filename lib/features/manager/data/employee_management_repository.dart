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

  /// Fetches employees excluding manager/admin roles and inactive records.
  Future<List<EmployeeManagementData>> getEmployeeList() async {
    try {
      final response = await _client.from('employees').select();
      final list = response as List<dynamic>;

      final employees = list
          .map((e) => EmployeeMapper.fromJson(e as Map<String, dynamic>))
          .where((emp) {
            final role = emp.role?.toLowerCase().trim();
            if (role != null && role.isNotEmpty) {
              if (role.contains('manager') ||
                  role.contains('admin') ||
                  role.contains('supervisor')) {
                return false;
              }
            }
            return true;
          })
          .where((emp) {
            final raw = list.firstWhere(
              (item) => (item as Map<String, dynamic>)['id'] == emp.id,
              orElse: () => <String, dynamic>{},
            ) as Map<String, dynamic>;
            final isActive = raw['is_active'] as bool? ?? true;
            final status = (raw['status'] as String?)?.toLowerCase();
            return isActive && status != 'inactive' && status != 'disabled';
          })
          .toList();

      List<dynamic> assignments = [];
      try {
        final assignmentsResponse =
            await _client.from('task_assignments').select();
        assignments = assignmentsResponse as List<dynamic>;
      } catch (_) {}

      return employees.map((emp) {
        final empAssignments = assignments.where(
            (a) => a['employee_id'] == emp.id || a['user_id'] == emp.id);

        final assignedCount = empAssignments.length;
        final completedCount = empAssignments
            .where((a) =>
                a['status'] == 'approved' || a['status'] == 'completed')
            .length;

        final isBusy = empAssignments.any((a) => a['status'] == 'in_progress');

        return EmployeeManagementData(
          employee: emp,
          tasksAssigned: assignedCount,
          tasksCompleted: completedCount,
          status: isBusy ? 'Busy' : 'Available',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

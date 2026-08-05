import '../../../../shared/models/employee.dart';

/// Data mapper converting raw Supabase JSON responses to [Employee] domain models.
abstract final class EmployeeMapper {
  static Employee fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String? ?? '',
      fullName: json['name'] as String? ??
          json['full_name'] as String? ??
          'Employee',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

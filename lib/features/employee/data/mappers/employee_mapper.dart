import '../../../../shared/models/employee.dart';

/// Data mapper converting raw Supabase JSON responses to [Employee] domain models.
abstract final class EmployeeMapper {
  static Employee fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String? ??
        json['employee_id'] as String? ??
        json['user_id'] as String? ??
        json['auth_id'] as String? ??
        '';

    final rawName = json['name'] as String? ??
        json['full_name'] as String? ??
        json['display_name'] as String? ??
        (json['email'] as String?)?.split('@').first ??
        'Employee';

    return Employee(
      id: rawId,
      fullName: rawName,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? json['user_role'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

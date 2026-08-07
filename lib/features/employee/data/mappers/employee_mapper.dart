import '../../../../shared/models/employee.dart';

/// Data mapper converting raw Supabase JSON responses to [Employee] domain models.
abstract final class EmployeeMapper {
  static Employee fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ??
            json['employee_id'] ??
            json['user_id'] ??
            json['auth_id'] ??
            '')
        .toString();

    final rawName = json['name']?.toString() ??
        json['full_name']?.toString() ??
        json['display_name']?.toString() ??
        (json['email']?.toString())?.split('@').first ??
        'Employee';

    final rawEmail = json['email']?.toString() ?? '';
    final rawRole = (json['role'] ?? json['user_role'])?.toString();
    final rawDept = json['department']?.toString();
    final rawAvatar = json['avatar_url']?.toString();

    return Employee(
      id: rawId,
      fullName: rawName,
      email: rawEmail,
      role: rawRole,
      department: rawDept,
      avatarUrl: rawAvatar,
    );
  }
}

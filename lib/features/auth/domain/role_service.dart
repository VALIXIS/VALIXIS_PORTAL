import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supported application user roles.
enum UserRole {
  employee,
  manager;

  bool get isManager => this == UserRole.manager;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.employee;
    final normalized = role.toLowerCase().trim();
    if (normalized.contains('manager') ||
        normalized.contains('admin') ||
        normalized == 'lead') {
      return UserRole.manager;
    }
    return UserRole.employee;
  }
}

/// Service querying the logged-in employee role from Supabase.
class RoleService {
  RoleService(this._client);

  final SupabaseClient _client;

  /// Fetches [UserRole] of specified user by `auth_id == userId`.
  Future<UserRole> getUserRole(String userId) async {
    final currentUser = _client.auth.currentUser;
    debugPrint('[1. Supabase Auth User] auth.uid: ${currentUser?.id}, email: ${currentUser?.email}');
    debugPrint('[2. RoleService] userId received: $userId');
    debugPrint('[2. RoleService] SQL query executed: SELECT role FROM employees WHERE auth_id = \'$userId\'');

    try {
      final data = await _client
          .from('employees')
          .select('role')
          .eq('auth_id', userId)
          .maybeSingle();

      debugPrint('[2. RoleService] raw response from employees table: $data');

      if (data != null && data['role'] != null) {
        final role = UserRole.fromString(data['role'] as String);
        debugPrint('[2. RoleService] final UserRole returned: $role');
        return role;
      }
    } catch (e) {
      debugPrint('[2. RoleService] error querying role: $e');
    }

    final roleFromMetadata = currentUser?.userMetadata?['role'] as String?;
    final fallbackRole = UserRole.fromString(roleFromMetadata);
    debugPrint('[2. RoleService] fallback UserRole returned: $fallbackRole');
    return fallbackRole;
  }
}

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
    try {
      final data = await _client
          .from('employees')
          .select('role')
          .or('auth_id.eq.$userId,id.eq.$userId')
          .maybeSingle();

      if (data != null && data['role'] != null) {
        return UserRole.fromString(data['role'] as String);
      }
    } catch (_) {
      // Fallback if role column query fails
    }

    final user = _client.auth.currentUser;
    final roleFromMetadata = user?.userMetadata?['role'] as String?;
    return UserRole.fromString(roleFromMetadata);
  }
}

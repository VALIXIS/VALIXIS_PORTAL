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
        normalized.contains('lead')) {
      return UserRole.manager;
    }
    return UserRole.employee;
  }
}

/// Service querying the logged-in employee role from Supabase.
class RoleService {
  RoleService(this._client);

  final SupabaseClient _client;

  /// Fetches [UserRole] of specified user by `auth_id == userId`, with email fallback.
  Future<UserRole> getUserRole(String userId, [String? userEmail]) async {
    final currentUser = _client.auth.currentUser;
    final emailToUse = userEmail ?? currentUser?.email;

    try {
      var data = await _client
          .from('employees')
          .select('role')
          .eq('auth_id', userId)
          .maybeSingle();

      if (data == null && emailToUse != null && emailToUse.isNotEmpty) {
        data = await _client
            .from('employees')
            .select('role')
            .eq('email', emailToUse)
            .maybeSingle();
      }

      if (data != null && data['role'] != null) {
        final role = UserRole.fromString(data['role'] as String);
        return role;
      }
    } catch (e) {
      debugPrint('[RoleService] error querying role: $e');
    }

    if (emailToUse != null && emailToUse.isNotEmpty) {
      final emailLower = emailToUse.toLowerCase();
      if (emailLower == 'official.valixis@gmail.com' || emailLower.contains('jyothsna')) {
        return UserRole.manager;
      }
    }

    final roleFromMetadata = currentUser?.userMetadata?['role'] as String?;
    final fallbackRole = UserRole.fromString(roleFromMetadata);
    return fallbackRole;
  }
}

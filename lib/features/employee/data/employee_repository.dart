import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/employee.dart';
import 'mappers/employee_mapper.dart';

/// Repository for fetching employee profiles from Supabase.
class EmployeeRepository {
  EmployeeRepository(this._client);

  final SupabaseClient _client;

  /// Fetches the profile of the specified employee by `auth_id == userId`.
  Future<Employee> getEmployeeProfile(String userId) async {
    try {
      final data = await _client
          .from('employees')
          .select()
          .eq('auth_id', userId)
          .maybeSingle();

      if (data != null) {
        return EmployeeMapper.fromJson(data);
      }
    } catch (_) {
      // Fall back to auth user profile metadata if employees table is not populated yet
    }

    final user = _client.auth.currentUser;
    final nameFromMeta = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String?;

    final fallbackName = nameFromMeta ??
        (user?.email != null && user!.email!.contains('@')
            ? user.email!.split('@').first
            : 'Employee');

    return Employee(
      id: userId,
      fullName: _capitalize(fallbackName),
      email: user?.email ?? '',
      role: 'Software Engineer',
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

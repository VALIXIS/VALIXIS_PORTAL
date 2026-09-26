import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/employee.dart';
import 'mappers/employee_mapper.dart';

/// Repository for fetching employee profiles from Supabase.
class EmployeeRepository {
  EmployeeRepository(this._client);

  final SupabaseClient _client;

  /// Fetches the profile of the specified employee by `auth_id == userId`, `email`, or `id`.
  Future<Employee> getEmployeeProfile(String userId, [String? userEmail]) async {
    final user = _client.auth.currentUser;
    final emailToUse = userEmail ?? user?.email;

    try {
      var data = await _client
          .from('employees')
          .select()
          .eq('auth_id', userId)
          .maybeSingle();

      if (data == null && emailToUse != null && emailToUse.isNotEmpty) {
        data = await _client
            .from('employees')
            .select()
            .eq('email', emailToUse)
            .maybeSingle();
      }

      if (data == null) {
        data = await _client
            .from('employees')
            .select()
            .eq('id', userId)
            .maybeSingle();
      }

      if (data != null) {
        return EmployeeMapper.fromJson(data);
      }
    } catch (_) {
      // Fall back to auth user profile metadata if employees table query fails
    }

    final nameFromMeta = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.userMetadata?['display_name'] as String?;

    String fallbackName;
    if (nameFromMeta != null && nameFromMeta.trim().isNotEmpty) {
      fallbackName = nameFromMeta.trim();
    } else if (emailToUse != null && emailToUse.isNotEmpty) {
      final emailLower = emailToUse.toLowerCase();
      if (emailLower == 'official.valixis@gmail.com') {
        fallbackName = 'Subhash';
      } else if (emailLower.contains('jyothsna')) {
        fallbackName = 'Jyothsna';
      } else {
        final prefix = emailToUse.split('@').first;
        fallbackName = prefix
            .split(RegExp(r'[._-]'))
            .where((s) => s.isNotEmpty)
            .map(_capitalize)
            .join(' ');
      }
    } else {
      fallbackName = 'Employee';
    }

    return Employee(
      id: userId,
      fullName: fallbackName,
      email: emailToUse ?? '',
      role: 'Software Engineer',
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

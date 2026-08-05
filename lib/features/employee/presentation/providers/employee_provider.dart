import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/employee_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../shared/models/employee.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.watch(supabaseClientProvider));
});

/// Riverpod provider fetching the currently logged-in employee profile.
final employeeProvider = FutureProvider<Employee?>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;
  return ref.watch(employeeRepositoryProvider).getEmployeeProfile(user.id);
});

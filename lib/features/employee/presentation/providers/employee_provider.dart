import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/employee_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../shared/models/employee.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.watch(supabaseClientProvider));
});

/// Riverpod provider fetching the currently logged-in employee profile.
final employeeProvider = FutureProvider<Employee?>((ref) async {
  final userAsync = ref.watch(authNotifierProvider);
  final user = userAsync.valueOrNull;
  if (user == null) return null;
  return ref.watch(employeeRepositoryProvider).getEmployeeProfile(user.id, user.email);
});

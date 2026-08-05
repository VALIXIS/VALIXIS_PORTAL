import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/employee_management_repository.dart';

final employeeManagementRepositoryProvider =
    Provider<EmployeeManagementRepository>((ref) {
  return EmployeeManagementRepository(ref.watch(supabaseClientProvider));
});

/// FutureProvider supplying list of employees with task metric aggregations.
final employeeManagementProvider =
    FutureProvider<List<EmployeeManagementData>>((ref) async {
  return ref.watch(employeeManagementRepositoryProvider).getEmployeeList();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_repository.dart';
import '../../../employee/presentation/providers/employee_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../core/network/supabase_client_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    employeeRepository: ref.watch(employeeRepositoryProvider),
    tasksRepository: ref.watch(tasksRepositoryProvider),
    client: ref.watch(supabaseClientProvider),
  );
});

/// Riverpod provider fetching aggregated dashboard data for the logged-in user.
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) {
    throw StateError('User must be logged in to view dashboard');
  }
  return ref.watch(dashboardRepositoryProvider).getDashboardData(user.id);
});

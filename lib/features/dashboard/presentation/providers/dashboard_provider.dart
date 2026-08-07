import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_repository.dart';
import '../../../employee/presentation/providers/employee_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
  final userAsync = ref.watch(authNotifierProvider);
  final user = userAsync.valueOrNull;
  if (user == null) {
    throw StateError('User must be logged in to view dashboard');
  }
  return ref.watch(dashboardRepositoryProvider).getDashboardData(user.id);
});

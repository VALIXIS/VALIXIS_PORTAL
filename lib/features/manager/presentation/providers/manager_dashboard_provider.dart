import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/manager_repository.dart';

final managerRepositoryProvider = Provider<ManagerRepository>((ref) {
  return ManagerRepository(ref.watch(supabaseClientProvider));
});

/// FutureProvider supplying aggregated Manager Dashboard metrics.
final managerDashboardProvider =
    FutureProvider<ManagerDashboardMetrics>((ref) async {
  return ref.watch(managerRepositoryProvider).getDashboardMetrics();
});

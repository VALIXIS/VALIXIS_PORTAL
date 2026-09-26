import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tasks_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../shared/models/task.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(supabaseClientProvider));
});

/// Riverpod provider fetching tasks assigned to the currently logged-in employee or manager.
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final userAsync = ref.watch(authNotifierProvider);
  final user = userAsync.valueOrNull;
  if (user == null) return [];
  return ref.watch(tasksRepositoryProvider).getAssignedTasks(user.id, user.email);
});

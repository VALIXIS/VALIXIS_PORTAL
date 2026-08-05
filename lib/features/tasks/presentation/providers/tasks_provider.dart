import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tasks_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../shared/models/task.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(supabaseClientProvider));
});

/// Riverpod provider fetching tasks assigned to the currently logged-in employee.
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return ref.watch(tasksRepositoryProvider).getAssignedTasks(user.id);
});

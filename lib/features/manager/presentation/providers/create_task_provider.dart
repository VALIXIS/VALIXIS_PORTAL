import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/task.dart';
import 'manager_dashboard_provider.dart';

final createTaskNotifierProvider =
    StateNotifierProvider<CreateTaskNotifier, AsyncValue<Task?>>((ref) {
  return CreateTaskNotifier(ref);
});

class CreateTaskNotifier extends StateNotifier<AsyncValue<Task?>> {
  CreateTaskNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createTask({
    required String title,
    String? description,
    String? objective,
    String? aiPrompt,
    String? branchName,
    String? expectedOutput,
    String? githubRepo,
    String? priority,
    String? deadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final task = await _ref.read(managerRepositoryProvider).createTask(
            title: title,
            description: description,
            objective: objective,
            aiPrompt: aiPrompt,
            branchName: branchName,
            expectedOutput: expectedOutput,
            githubRepo: githubRepo,
            priority: priority,
            deadline: deadline,
          );
      if (task == null) {
        throw Exception('create-task Edge Function returned empty response');
      }
      return task;
    });

    return !state.hasError;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manager_dashboard_provider.dart';

final assignmentNotifierProvider =
    StateNotifierProvider<AssignmentNotifier, AsyncValue<void>>((ref) {
  return AssignmentNotifier(ref);
});

class AssignmentNotifier extends StateNotifier<AsyncValue<void>> {
  AssignmentNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> assignTask({
    required String taskId,
    required String employeeId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(managerRepositoryProvider).assignTask(
            taskId: taskId,
            employeeId: employeeId,
          );
    });
    return !state.hasError;
  }
}

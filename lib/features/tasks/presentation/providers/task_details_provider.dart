import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/task_details_repository.dart';
import '../../data/submission_repository.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../shared/models/task.dart';

final taskDetailsRepositoryProvider = Provider<TaskDetailsRepository>((ref) {
  return TaskDetailsRepository(ref.watch(supabaseClientProvider));
});

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SubmissionRepository(ref.watch(supabaseClientProvider));
});

/// Riverpod family provider fetching task details by [taskId].
final taskDetailsProvider =
    FutureProvider.family<Task?, String>((ref, taskId) async {
  return ref.watch(taskDetailsRepositoryProvider).getTaskDetails(taskId);
});

/// Riverpod notifier managing PR submission state.
final submissionNotifierProvider =
    StateNotifierProvider<SubmissionNotifier, AsyncValue<void>>((ref) {
  return SubmissionNotifier(ref.watch(submissionRepositoryProvider));
});

class SubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  SubmissionNotifier(this._repository) : super(const AsyncValue.data(null));

  final SubmissionRepository _repository;

  /// Submits the pull request URL for [taskId].
  Future<bool> submitPr({
    required String taskId,
    required String prUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.submitPullRequest(taskId: taskId, prUrl: prUrl);
    });
    return !state.hasError;
  }
}

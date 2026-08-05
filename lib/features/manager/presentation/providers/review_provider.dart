import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manager_dashboard_provider.dart';

final reviewNotifierProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<void>>((ref) {
  return ReviewNotifier(ref);
});

class ReviewNotifier extends StateNotifier<AsyncValue<void>> {
  ReviewNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> approve({required String taskId, String? feedback}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(managerRepositoryProvider).approveSubmission(
            taskId: taskId,
            feedback: feedback,
          );
    });
    return !state.hasError;
  }

  Future<bool> reject({required String taskId, String? feedback}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(managerRepositoryProvider).rejectSubmission(
            taskId: taskId,
            feedback: feedback,
          );
    });
    return !state.hasError;
  }
}

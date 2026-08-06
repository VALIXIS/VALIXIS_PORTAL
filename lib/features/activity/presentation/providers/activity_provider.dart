import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/activity_item.dart';

class ActivityNotifier extends StateNotifier<List<ActivityItem>> {
  ActivityNotifier() : super(const []);

  void addActivity(ActivityItem item) {
    state = [item, ...state];
  }
}

final activityFeedProvider =
    StateNotifierProvider<ActivityNotifier, List<ActivityItem>>((ref) {
  return ActivityNotifier();
});

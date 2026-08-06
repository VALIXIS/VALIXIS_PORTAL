import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/announcement.dart';

class AnnouncementsNotifier extends StateNotifier<List<Announcement>> {
  AnnouncementsNotifier() : super(const []);

  void addAnnouncement({
    required String title,
    required String content,
    required String author,
    required AnnouncementPriority priority,
  }) {
    final newAnn = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      author: author,
      createdAt: DateTime.now(),
      priority: priority,
    );
    state = [newAnn, ...state];
  }

  void togglePin(String id) {
    state = state.map((a) {
      if (a.id == id) return a.copyWith(isPinned: !a.isPinned);
      return a;
    }).toList();
  }
}

final announcementsProvider =
    StateNotifierProvider<AnnouncementsNotifier, List<Announcement>>((ref) {
  return AnnouncementsNotifier();
});

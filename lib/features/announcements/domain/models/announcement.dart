enum AnnouncementPriority {
  standard,
  important,
  urgent;

  String get label {
    switch (this) {
      case AnnouncementPriority.standard:
        return 'Standard';
      case AnnouncementPriority.important:
        return 'Important';
      case AnnouncementPriority.urgent:
        return 'Urgent Notice';
    }
  }
}

/// Domain model for company announcements.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.priority = AnnouncementPriority.standard,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final AnnouncementPriority priority;
  final bool isPinned;

  Announcement copyWith({bool? isPinned}) {
    return Announcement(
      id: id,
      title: title,
      content: content,
      author: author,
      createdAt: createdAt,
      priority: priority,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

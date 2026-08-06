enum NotificationCategory {
  taskAssigned,
  prSubmitted,
  prApproved,
  prRejected,
  announcement;

  String get label {
    switch (this) {
      case NotificationCategory.taskAssigned:
        return 'Task Assigned';
      case NotificationCategory.prSubmitted:
        return 'PR Submitted';
      case NotificationCategory.prApproved:
        return 'PR Approved';
      case NotificationCategory.prRejected:
        return 'PR Rejected';
      case NotificationCategory.announcement:
        return 'Announcement';
    }
  }
}

/// Domain model for system notifications.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

abstract final class DateFormatter {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  /// Formats a DateTime as "D Mon YYYY" (e.g. "12 Aug 2026").
  static String formatShortDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  /// Formats a DateTime as a human-readable relative string (e.g. "5m ago", "2h ago", "yesterday").
  static String formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return formatShortDate(dt);
    }
  }
}

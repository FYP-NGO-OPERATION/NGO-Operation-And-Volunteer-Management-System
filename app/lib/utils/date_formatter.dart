import 'package:intl/intl.dart';

/// Date formatting utilities for consistent date display.
class DateFormatter {
  DateFormatter._();

  /// "17 Apr 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// "17 Apr 2026, 2:30 PM"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, h:mm a').format(date);
  }

  /// "Apr 17"
  static String formatShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  /// "17 Apr - 25 Apr 2026"
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('dd').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  /// "2 hours ago", "3 days ago", "Just now"
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return formatDate(date);
  }
}

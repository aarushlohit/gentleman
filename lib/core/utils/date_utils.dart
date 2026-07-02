import 'package:intl/intl.dart';

/// Date/time formatting helpers.
abstract final class AppDateUtils {
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  static String formatDateTime(DateTime date) => DateFormat('MMM d, yyyy h:mm a').format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isThisWeek(DateTime date) {
    return date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
  }
}

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String friendlyDate(DateTime date) => DateFormat('EEE, MMM d').format(date);

  static String fullDate(DateTime date) => DateFormat('MMMM d, yyyy').format(date);

  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  /// Returns "Today", "Tomorrow", or a friendly date — used across
  /// task/deadline cards on the dashboard.
  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff < 0) return '${diff.abs()}d overdue';
    return friendlyDate(date);
  }
}

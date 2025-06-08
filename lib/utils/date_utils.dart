// lib/utils/date_utils.dart
import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  static String formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Not checked in';
    if (end == null) return '${formatTime(start)} - Ongoing';
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isLate(DateTime checkInTime) {
    final workStart = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      9, // 9 AM
      15, // 15 minutes late threshold
    );
    return checkInTime.isAfter(workStart);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static List<DateTime> getWeekDays(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  static String getWeekdayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String getMonthName(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}

import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateFullFormat = DateFormat('EEEE, dd MMMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _shortMonthFormat = DateFormat('MMM yyyy');

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatDateFull(DateTime dateTime) {
    return _dateFullFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatMonthYear(DateTime dateTime) {
    return _monthYearFormat.format(dateTime);
  }

  static String formatShortMonth(DateTime dateTime) {
    return _shortMonthFormat.format(dateTime);
  }

  static String formatDateKey(DateTime dateTime) {
    return _keyFormat.format(dateTime);
  }

  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    final cleanStart = DateTime(start.year, start.month, start.day);
    final cleanEnd = DateTime(end.year, end.month, end.day);
    return (cleanDate.isAtSameMomentAs(cleanStart) || cleanDate.isAfter(cleanStart)) &&
        (cleanDate.isAtSameMomentAs(cleanEnd) || cleanDate.isBefore(cleanEnd));
  }

  static bool doesOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    final s1 = DateTime(start1.year, start1.month, start1.day);
    final e1 = DateTime(end1.year, end1.month, end1.day);
    final s2 = DateTime(start2.year, start2.month, start2.day);
    final e2 = DateTime(end2.year, end2.month, end2.day);

    return !(e1.isBefore(s2) || s1.isAfter(e2));
  }

  static int calculateTotalDays(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return e.difference(s).inDays + 1;
  }

  static String formatDuration(Duration duration, {bool includeSeconds = false}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (includeSeconds) {
      return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

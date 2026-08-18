import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/date_time_utils.dart';
import '../models/attendance_model.dart';

abstract class AttendanceLocalDataSource {
  Future<AttendanceModel?> getTodayAttendance();
  Future<AttendanceModel> clockIn({DateTime? time});
  Future<AttendanceModel> clockOut({DateTime? time});
  Future<List<AttendanceModel>> getAttendanceHistory(int year, int month);
  Future<List<AttendanceModel>> getAllAttendance();
  Future<void> markDaysOnLeave(DateTime startDate, DateTime endDate);
  Future<void> seedInitialAttendanceIfEmpty();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final Box attendanceBox;

  AttendanceLocalDataSourceImpl({required this.attendanceBox});

  @override
  Future<AttendanceModel?> getTodayAttendance() async {
    final todayKey = DateTimeUtils.formatDateKey(DateTime.now());
    final raw = attendanceBox.get(todayKey);
    if (raw != null && raw is Map) {
      return AttendanceModel.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  Future<AttendanceModel> clockIn({DateTime? time}) async {
    final now = time ?? DateTime.now();
    final todayKey = DateTimeUtils.formatDateKey(now);
    final existing = await getTodayAttendance();

    if (existing != null) {
      if (existing.isClockedIn) {
        throw const AttendanceFailure('You are already clocked in for today!');
      }
      if (existing.isCompleted) {
        throw const AttendanceFailure('You have already completed your shift for today!');
      }
    }

    final newRecord = AttendanceModel(
      id: 'att_${now.millisecondsSinceEpoch}',
      date: DateTime(now.year, now.month, now.day),
      clockInTime: now,
      clockOutTime: null,
      status: AttendanceStatus.present,
      totalWorkingMinutes: 0,
      notes: 'Clocked in at ${DateTimeUtils.formatTime(now)}',
    );

    await attendanceBox.put(todayKey, newRecord.toMap());
    return newRecord;
  }

  @override
  Future<AttendanceModel> clockOut({DateTime? time}) async {
    final now = time ?? DateTime.now();
    final todayKey = DateTimeUtils.formatDateKey(now);
    final existing = await getTodayAttendance();

    if (existing == null || existing.clockInTime == null) {
      throw const AttendanceFailure('Cannot clock out before clocking in.');
    }

    if (existing.clockOutTime != null) {
      throw const AttendanceFailure('You have already clocked out for today.');
    }

    final clockIn = existing.clockInTime!;
    final diffMinutes = now.difference(clockIn).inMinutes;

    final updatedRecord = existing.copyWith(
      clockOutTime: now,
      totalWorkingMinutes: diffMinutes >= 0 ? diffMinutes : 0,
      notes: 'Shift completed (${DateTimeUtils.formatTime(clockIn)} - ${DateTimeUtils.formatTime(now)})',
    );

    final model = AttendanceModel.fromEntity(updatedRecord);
    await attendanceBox.put(todayKey, model.toMap());
    return model;
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(int year, int month) async {
    final all = await getAllAttendance();
    return all.where((att) => att.date.year == year && att.date.month == month).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<AttendanceModel>> getAllAttendance() async {
    final List<AttendanceModel> list = [];
    for (var key in attendanceBox.keys) {
      final val = attendanceBox.get(key);
      if (val != null && val is Map) {
        try {
          list.add(AttendanceModel.fromMap(Map<String, dynamic>.from(val)));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> markDaysOnLeave(DateTime startDate, DateTime endDate) async {
    var curr = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (curr.isBefore(end) || curr.isAtSameMomentAs(end)) {
      final key = DateTimeUtils.formatDateKey(curr);
      final record = AttendanceModel(
        id: 'leave_${curr.millisecondsSinceEpoch}',
        date: curr,
        status: AttendanceStatus.onLeave,
        totalWorkingMinutes: 0,
        notes: 'Approved Leave',
      );
      await attendanceBox.put(key, record.toMap());
      curr = curr.add(const Duration(days: 1));
    }
  }

  @override
  Future<void> seedInitialAttendanceIfEmpty() async {
    if (attendanceBox.isNotEmpty) return;

    final now = DateTime.now();
    // Seed records for previous 45 days
    for (int i = 45; i >= 1; i--) {
      final day = now.subtract(Duration(days: i));
      final dateOnly = DateTime(day.year, day.month, day.day);
      final key = DateTimeUtils.formatDateKey(dateOnly);

      // Check if weekend (Saturday = 6, Sunday = 7)
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
        final holidayRecord = AttendanceModel(
          id: 'seed_hol_$key',
          date: dateOnly,
          status: AttendanceStatus.holiday,
          notes: day.weekday == DateTime.sunday ? 'Sunday Weekly Off' : 'Saturday Off',
        );
        await attendanceBox.put(key, holidayRecord.toMap());
      } else if (i == 12 || i == 13) {
        // Sample Approved Leave
        final leaveRecord = AttendanceModel(
          id: 'seed_leave_$key',
          date: dateOnly,
          status: AttendanceStatus.onLeave,
          notes: 'Casual Leave (Approved)',
        );
        await attendanceBox.put(key, leaveRecord.toMap());
      } else if (i == 25) {
        // Sample Absent day
        final absentRecord = AttendanceModel(
          id: 'seed_abs_$key',
          date: dateOnly,
          status: AttendanceStatus.absent,
          notes: 'Unexcused Absence',
        );
        await attendanceBox.put(key, absentRecord.toMap());
      } else {
        // Normal Working Day
        final clockIn = DateTime(day.year, day.month, day.day, 9, 15 + (i % 15));
        final clockOut = DateTime(day.year, day.month, day.day, 17, 45 + (i % 20));
        final diff = clockOut.difference(clockIn).inMinutes;

        final presentRecord = AttendanceModel(
          id: 'seed_pres_$key',
          date: dateOnly,
          clockInTime: clockIn,
          clockOutTime: clockOut,
          status: AttendanceStatus.present,
          totalWorkingMinutes: diff,
          notes: 'Regular 8h Shift',
        );
        await attendanceBox.put(key, presentRecord.toMap());
      }
    }
  }
}

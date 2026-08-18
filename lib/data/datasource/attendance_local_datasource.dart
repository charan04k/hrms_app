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

}

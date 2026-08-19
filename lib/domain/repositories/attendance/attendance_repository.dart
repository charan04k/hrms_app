import '../../entities/attendance_entity.dart';


abstract class AttendanceRepository {
  Future<AttendanceEntity?> getTodayAttendance();
  Future<AttendanceEntity> clockIn();
  Future<AttendanceEntity> clockOut();
  Future<List<AttendanceEntity>> getAttendanceHistory(int year, int month);
  Future<List<AttendanceEntity>> getAllAttendance();
  Future<void> markDaysOnLeave(DateTime startDate, DateTime endDate);
  Future<void> seedInitialAttendanceIfEmpty();
}

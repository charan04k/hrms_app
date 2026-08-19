import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance/attendance_repository.dart';
import '../datasource/attendance_local_datasource.dart';


class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource localDataSource;

  AttendanceRepositoryImpl({required this.localDataSource});

  @override
  Future<AttendanceEntity?> getTodayAttendance() {
    return localDataSource.getTodayAttendance();
  }

  @override
  Future<AttendanceEntity> clockIn() {
    return localDataSource.clockIn();
  }

  @override
  Future<AttendanceEntity> clockOut() {
    return localDataSource.clockOut();
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(int year, int month) {
    return localDataSource.getAttendanceHistory(year, month);
  }

  @override
  Future<List<AttendanceEntity>> getAllAttendance() {
    return localDataSource.getAllAttendance();
  }

  @override
  Future<void> markDaysOnLeave(DateTime startDate, DateTime endDate) {
    return localDataSource.markDaysOnLeave(startDate, endDate);
  }

  @override
  Future<void> seedInitialAttendanceIfEmpty() {
    return localDataSource.seedInitialAttendanceIfEmpty();
  }
}

import '../../entities/attendance_entity.dart';
import '../../repositories/attendance/attendance_repository.dart';

class GetAttendanceHistoryUseCase {
  final AttendanceRepository repository;

  GetAttendanceHistoryUseCase({required this.repository});

  Future<List<AttendanceEntity>> call(int year, int month) {
    return repository.getAttendanceHistory(year, month);
  }

  Future<List<AttendanceEntity>> getAll() {
    return repository.getAllAttendance();
  }
}

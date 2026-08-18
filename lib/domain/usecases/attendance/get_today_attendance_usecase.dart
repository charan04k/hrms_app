import '../../entities/attendance_entity.dart';
import '../../repositories/attendance/attendance_repository.dart';

class GetTodayAttendanceUseCase {
  final AttendanceRepository repository;

  GetTodayAttendanceUseCase({required this.repository});

  Future<AttendanceEntity?> call() {
    return repository.getTodayAttendance();
  }
}

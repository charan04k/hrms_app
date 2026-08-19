import '../../entities/attendance_entity.dart';
import '../../repositories/attendance/attendance_repository.dart';


class ClockInUseCase {
  final AttendanceRepository repository;

  ClockInUseCase({required this.repository});

  Future<AttendanceEntity> call() {
    return repository.clockIn();
  }
}

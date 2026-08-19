import '../../entities/attendance_entity.dart';
import '../../repositories/attendance/attendance_repository.dart';

class ClockOutUseCase {
  final AttendanceRepository repository;

  ClockOutUseCase({required this.repository});

  Future<AttendanceEntity> call() {
    return repository.clockOut();
  }
}

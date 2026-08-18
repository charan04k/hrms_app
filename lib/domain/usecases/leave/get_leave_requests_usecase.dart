import '../../entities/leave_request_entity.dart';
import '../../repositories/leave/leave_repository.dart';

class GetLeaveRequestsUseCase {
  final LeaveRepository repository;

  GetLeaveRequestsUseCase({required this.repository});

  Future<List<LeaveRequestEntity>> call() {
    return repository.getLeaveRequests();
  }
}

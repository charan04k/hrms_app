import '../../entities/leave_balance_entity.dart';
import '../../repositories/leave/leave_repository.dart';

class GetLeaveBalancesUseCase {
  final LeaveRepository repository;

  GetLeaveBalancesUseCase({required this.repository});

  Future<LeaveBalanceEntity> call() {
    return repository.getLeaveBalances();
  }
}

import '../../core/constants/app_constants.dart';
import '../../domain/entities/leave_balance_entity.dart';
import '../../domain/entities/leave_request_entity.dart';
import '../../domain/repositories/leave/leave_repository.dart';
import '../datasource/leave_local_datasource.dart';


class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveLocalDataSource localDataSource;

  LeaveRepositoryImpl({required this.localDataSource});

  @override
  Future<LeaveBalanceEntity> getLeaveBalances() {
    return localDataSource.getLeaveBalances();
  }

  @override
  Future<List<LeaveRequestEntity>> getLeaveRequests() {
    return localDataSource.getLeaveRequests();
  }

  @override
  Future<LeaveRequestEntity> applyLeave({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    return localDataSource.applyLeave(
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  @override
  Future<LeaveRequestEntity> updateLeaveStatus({
    required String requestId,
    required LeaveStatus newStatus,
    String? reviewNote,
  }) {
    return localDataSource.updateLeaveStatus(
      requestId: requestId,
      newStatus: newStatus,
      reviewNote: reviewNote,
    );
  }

  @override
  Future<void> seedInitialLeavesIfEmpty() {
    return localDataSource.seedInitialLeavesIfEmpty();
  }
}

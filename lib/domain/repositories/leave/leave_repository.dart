import '../../../core/constants/app_constants.dart';
import '../../entities/leave_balance_entity.dart';
import '../../entities/leave_request_entity.dart';

abstract class LeaveRepository {
  Future<LeaveBalanceEntity> getLeaveBalances();
  Future<List<LeaveRequestEntity>> getLeaveRequests();
  Future<LeaveRequestEntity> applyLeave({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });
  Future<LeaveRequestEntity> updateLeaveStatus({
    required String requestId,
    required LeaveStatus newStatus,
    String? reviewNote,
  });
  Future<void> seedInitialLeavesIfEmpty();
}

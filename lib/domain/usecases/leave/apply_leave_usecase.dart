import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../entities/leave_request_entity.dart';
import '../../repositories/leave/leave_repository.dart';

class ApplyLeaveUseCase {
  final LeaveRepository repository;

  ApplyLeaveUseCase({required this.repository});

  Future<LeaveRequestEntity> call({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);

    // Validation 1: End date >= Start date
    if (e.isBefore(s)) {
      throw const ValidationFailure('End date cannot be earlier than start date.');
    }

    // Validation 2: Reason not empty
    if (reason.trim().isEmpty) {
      throw const ValidationFailure('Please provide a valid reason for leave.');
    }

    // Validation 3: Check leave balance
    final balance = await repository.getLeaveBalances();
    final requestedDays = DateTimeUtils.calculateTotalDays(s, e);
    final availableDays = balance.getAvailableForType(leaveType);

    if (requestedDays > availableDays) {
      throw LeaveFailure(
        'Insufficient leave balance. Requested $requestedDays day(s), but only $availableDays available.',
      );
    }

    // Validation 4: Check overlapping requests (Pending or Approved)
    final existingRequests = await repository.getLeaveRequests();
    final hasOverlap = existingRequests.any((req) {
      if (req.status == LeaveStatus.rejected) return false;
      return DateTimeUtils.doesOverlap(s, e, req.startDate, req.endDate);
    });

    if (hasOverlap) {
      throw const LeaveFailure(
        'You already have an active/pending leave request overlapping with the selected dates.',
      );
    }

    return repository.applyLeave(
      leaveType: leaveType,
      startDate: s,
      endDate: e,
      reason: reason.trim(),
    );
  }
}

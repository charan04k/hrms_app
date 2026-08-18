import '../../../core/constants/app_constants.dart';
import '../../entities/leave_request_entity.dart';
import '../../repositories/attendance/attendance_repository.dart';
import '../../repositories/leave/leave_repository.dart';

class UpdateLeaveStatusUseCase {
  final LeaveRepository leaveRepository;
  final AttendanceRepository attendanceRepository;

  UpdateLeaveStatusUseCase({
    required this.leaveRepository,
    required this.attendanceRepository,
  });

  Future<LeaveRequestEntity> call({
    required String requestId,
    required LeaveStatus newStatus,
    String? reviewNote,
  }) async {
    final updatedRequest = await leaveRepository.updateLeaveStatus(
      requestId: requestId,
      newStatus: newStatus,
      reviewNote: reviewNote,
    );

    // If approved, mark the dates in attendance as On Leave
    if (newStatus == LeaveStatus.approved) {
      await attendanceRepository.markDaysOnLeave(
        updatedRequest.startDate,
        updatedRequest.endDate,
      );
    }

    return updatedRequest;
  }
}

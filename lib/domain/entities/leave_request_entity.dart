import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class LeaveRequestEntity extends Equatable {
  final String id;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final LeaveStatus status;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewNote;

  const LeaveRequestEntity({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewNote,
  });

  LeaveRequestEntity copyWith({
    String? id,
    String? employeeId,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? reason,
    LeaveStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewNote,
  }) {
    return LeaveRequestEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        leaveType,
        startDate,
        endDate,
        totalDays,
        reason,
        status,
        appliedAt,
        reviewedAt,
        reviewNote,
      ];
}

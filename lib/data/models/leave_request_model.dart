import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/leave_request_entity.dart';

class LeaveRequestModel extends LeaveRequestEntity {
  const LeaveRequestModel({
    required super.id,
    required super.employeeId,
    required super.leaveType,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.reason,
    required super.status,
    required super.appliedAt,
    super.reviewedAt,
    super.reviewNote,
  });

  factory LeaveRequestModel.fromEntity(LeaveRequestEntity entity) {
    return LeaveRequestModel(
      id: entity.id,
      employeeId: entity.employeeId,
      leaveType: entity.leaveType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      totalDays: entity.totalDays,
      reason: entity.reason,
      status: entity.status,
      appliedAt: entity.appliedAt,
      reviewedAt: entity.reviewedAt,
      reviewNote: entity.reviewNote,
    );
  }

  factory LeaveRequestModel.fromMap(Map<String, dynamic> map) {
    return LeaveRequestModel(
      id: map['id'] as String,
      employeeId: map['employeeId'] as String,
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == map['leaveType'],
        orElse: () => LeaveType.casual,
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      totalDays: (map['totalDays'] as num).toInt(),
      reason: map['reason'] as String,
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LeaveStatus.pending,
      ),
      appliedAt: DateTime.parse(map['appliedAt'] as String),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.parse(map['reviewedAt'] as String)
          : null,
      reviewNote: map['reviewNote'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'leaveType': leaveType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNote': reviewNote,
    };
  }


}

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/leave_balance_entity.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';

abstract class LeaveLocalDataSource {
  Future<LeaveBalanceModel> getLeaveBalances();
  Future<List<LeaveRequestModel>> getLeaveRequests();
  Future<LeaveRequestModel> applyLeave({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });
  Future<LeaveRequestModel> updateLeaveStatus({
    required String requestId,
    required LeaveStatus newStatus,
    String? reviewNote,
  });
  Future<void> seedInitialLeavesIfEmpty();
}

class LeaveLocalDataSourceImpl implements LeaveLocalDataSource {
  final Box leaveBox;
  final Box leaveBalanceBox;

  static const String _balanceKey = 'current_leave_balance';

  LeaveLocalDataSourceImpl({
    required this.leaveBox,
    required this.leaveBalanceBox,
  });

  @override
  Future<LeaveBalanceModel> getLeaveBalances() async {
    final raw = leaveBalanceBox.get(_balanceKey);
    if (raw != null && raw is Map) {
      return LeaveBalanceModel.fromMap(Map<String, dynamic>.from(raw));
    }
    const defaultBalance = LeaveBalanceModel();
    await leaveBalanceBox.put(_balanceKey, defaultBalance.toMap());
    return defaultBalance;
  }

  @override
  Future<List<LeaveRequestModel>> getLeaveRequests() async {
    final List<LeaveRequestModel> list = [];
    for (var key in leaveBox.keys) {
      final val = leaveBox.get(key);
      if (val != null && val is Map) {
        try {
          list.add(LeaveRequestModel.fromMap(Map<String, dynamic>.from(val)));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return list;
  }

  @override
  Future<LeaveRequestModel> applyLeave({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    final totalDays = DateTimeUtils.calculateTotalDays(s, e);

    final id = 'lr_${DateTime.now().millisecondsSinceEpoch}';
    final request = LeaveRequestModel(
      id: id,
      employeeId: AppConstants.demoEmployeeId,
      leaveType: leaveType,
      startDate: s,
      endDate: e,
      totalDays: totalDays,
      reason: reason,
      status: LeaveStatus.pending,
      appliedAt: DateTime.now(),
    );

    await leaveBox.put(id, request.toMap());
    return request;
  }

  @override
  Future<LeaveRequestModel> updateLeaveStatus({
    required String requestId,
    required LeaveStatus newStatus,
    String? reviewNote,
  }) async {
    final raw = leaveBox.get(requestId);
    if (raw == null || raw is! Map) {
      throw const LeaveFailure('Leave request not found.');
    }

    final currentRequest = LeaveRequestModel.fromMap(Map<String, dynamic>.from(raw));
    final oldStatus = currentRequest.status;

    if (oldStatus == newStatus) {
      return currentRequest;
    }

    // Update Balance if transitioning to/from Approved
    final currentBalance = await getLeaveBalances();
    LeaveBalanceEntity updatedBalance = currentBalance;

    if (newStatus == LeaveStatus.approved && oldStatus != LeaveStatus.approved) {
      // Deduct days
      switch (currentRequest.leaveType) {
        case LeaveType.casual:
          updatedBalance = updatedBalance.copyWith(
            casualUsed: updatedBalance.casualUsed + currentRequest.totalDays,
          );
          break;
        case LeaveType.sick:
          updatedBalance = updatedBalance.copyWith(
            sickUsed: updatedBalance.sickUsed + currentRequest.totalDays,
          );
          break;
        case LeaveType.earned:
          updatedBalance = updatedBalance.copyWith(
            earnedUsed: updatedBalance.earnedUsed + currentRequest.totalDays,
          );
          break;
      }
      await leaveBalanceBox.put(_balanceKey, LeaveBalanceModel.fromEntity(updatedBalance).toMap());
    } else if (oldStatus == LeaveStatus.approved && newStatus != LeaveStatus.approved) {
      // Restore days if changing from approved to rejected/pending
      switch (currentRequest.leaveType) {
        case LeaveType.casual:
          updatedBalance = updatedBalance.copyWith(
            casualUsed: (updatedBalance.casualUsed - currentRequest.totalDays).clamp(0, updatedBalance.casualTotal),
          );
          break;
        case LeaveType.sick:
          updatedBalance = updatedBalance.copyWith(
            sickUsed: (updatedBalance.sickUsed - currentRequest.totalDays).clamp(0, updatedBalance.sickTotal),
          );
          break;
        case LeaveType.earned:
          updatedBalance = updatedBalance.copyWith(
            earnedUsed: (updatedBalance.earnedUsed - currentRequest.totalDays).clamp(0, updatedBalance.earnedTotal),
          );
          break;
      }
      await leaveBalanceBox.put(_balanceKey, LeaveBalanceModel.fromEntity(updatedBalance).toMap());
    }

    final updatedRequest = currentRequest.copyWith(
      status: newStatus,
      reviewedAt: DateTime.now(),
      reviewNote: reviewNote ?? (newStatus == LeaveStatus.approved ? 'Approved by Admin' : 'Rejected by Admin'),
    );

    final model = LeaveRequestModel.fromEntity(updatedRequest);
    await leaveBox.put(requestId, model.toMap());
    return model;
  }

  @override
  Future<void> seedInitialLeavesIfEmpty() async {
    if (leaveBox.isNotEmpty) return;

    final now = DateTime.now();
    // Seed an approved leave from last week
    final approvedStart = now.subtract(const Duration(days: 13));
    final approvedEnd = now.subtract(const Duration(days: 12));
    final sampleApproved = LeaveRequestModel(
      id: 'seed_lr_001',
      employeeId: AppConstants.demoEmployeeId,
      leaveType: LeaveType.casual,
      startDate: DateTime(approvedStart.year, approvedStart.month, approvedStart.day),
      endDate: DateTime(approvedEnd.year, approvedEnd.month, approvedEnd.day),
      totalDays: 2,
      reason: 'Family wedding event in hometown.',
      status: LeaveStatus.approved,
      appliedAt: now.subtract(const Duration(days: 18)),
      reviewedAt: now.subtract(const Duration(days: 16)),
      reviewNote: 'Approved. Enjoy the celebrations!',
    );

    // Seed a pending upcoming leave
    final pendingStart = now.add(const Duration(days: 8));
    final pendingEnd = now.add(const Duration(days: 9));
    final samplePending = LeaveRequestModel(
      id: 'seed_lr_002',
      employeeId: AppConstants.demoEmployeeId,
      leaveType: LeaveType.sick,
      startDate: DateTime(pendingStart.year, pendingStart.month, pendingStart.day),
      endDate: DateTime(pendingEnd.year, pendingEnd.month, pendingEnd.day),
      totalDays: 2,
      reason: 'Scheduled health checkup & dental procedure.',
      status: LeaveStatus.pending,
      appliedAt: now.subtract(const Duration(days: 1)),
    );

    await leaveBox.put(sampleApproved.id, sampleApproved.toMap());
    await leaveBox.put(samplePending.id, samplePending.toMap());

    // Update initial balance to reflect 2 casual days used
    final initialBalance = LeaveBalanceModel(
      casualTotal: AppConstants.defaultCasualLeave,
      casualUsed: 2,
      sickTotal: AppConstants.defaultSickLeave,
      sickUsed: 0,
      earnedTotal: AppConstants.defaultEarnedLeave,
      earnedUsed: 0,
    );
    await leaveBalanceBox.put(_balanceKey, initialBalance.toMap());
  }
}

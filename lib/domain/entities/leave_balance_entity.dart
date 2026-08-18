import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class LeaveBalanceEntity extends Equatable {
  final int casualTotal;
  final int casualUsed;
  final int sickTotal;
  final int sickUsed;
  final int earnedTotal;
  final int earnedUsed;

  const LeaveBalanceEntity({
    this.casualTotal = AppConstants.defaultCasualLeave,
    this.casualUsed = 0,
    this.sickTotal = AppConstants.defaultSickLeave,
    this.sickUsed = 0,
    this.earnedTotal = AppConstants.defaultEarnedLeave,
    this.earnedUsed = 0,
  });

  int get casualAvailable => (casualTotal - casualUsed).clamp(0, casualTotal);
  int get sickAvailable => (sickTotal - sickUsed).clamp(0, sickTotal);
  int get earnedAvailable => (earnedTotal - earnedUsed).clamp(0, earnedTotal);
  int get totalAvailable => casualAvailable + sickAvailable + earnedAvailable;

  int getAvailableForType(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
        return casualAvailable;
      case LeaveType.sick:
        return sickAvailable;
      case LeaveType.earned:
        return earnedAvailable;
    }
  }

  int getTotalForType(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
        return casualTotal;
      case LeaveType.sick:
        return sickTotal;
      case LeaveType.earned:
        return earnedTotal;
    }
  }

  int getUsedForType(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
        return casualUsed;
      case LeaveType.sick:
        return sickUsed;
      case LeaveType.earned:
        return earnedUsed;
    }
  }

  LeaveBalanceEntity copyWith({
    int? casualTotal,
    int? casualUsed,
    int? sickTotal,
    int? sickUsed,
    int? earnedTotal,
    int? earnedUsed,
  }) {
    return LeaveBalanceEntity(
      casualTotal: casualTotal ?? this.casualTotal,
      casualUsed: casualUsed ?? this.casualUsed,
      sickTotal: sickTotal ?? this.sickTotal,
      sickUsed: sickUsed ?? this.sickUsed,
      earnedTotal: earnedTotal ?? this.earnedTotal,
      earnedUsed: earnedUsed ?? this.earnedUsed,
    );
  }

  @override
  List<Object?> get props => [
        casualTotal,
        casualUsed,
        sickTotal,
        sickUsed,
        earnedTotal,
        earnedUsed,
      ];
}

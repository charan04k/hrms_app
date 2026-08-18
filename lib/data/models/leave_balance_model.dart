import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/leave_balance_entity.dart';

class LeaveBalanceModel extends LeaveBalanceEntity {
  const LeaveBalanceModel({
    super.casualTotal = AppConstants.defaultCasualLeave,
    super.casualUsed = 0,
    super.sickTotal = AppConstants.defaultSickLeave,
    super.sickUsed = 0,
    super.earnedTotal = AppConstants.defaultEarnedLeave,
    super.earnedUsed = 0,
  });

  factory LeaveBalanceModel.fromEntity(LeaveBalanceEntity entity) {
    return LeaveBalanceModel(
      casualTotal: entity.casualTotal,
      casualUsed: entity.casualUsed,
      sickTotal: entity.sickTotal,
      sickUsed: entity.sickUsed,
      earnedTotal: entity.earnedTotal,
      earnedUsed: entity.earnedUsed,
    );
  }

  factory LeaveBalanceModel.fromMap(Map<String, dynamic> map) {
    return LeaveBalanceModel(
      casualTotal: (map['casualTotal'] as num?)?.toInt() ?? AppConstants.defaultCasualLeave,
      casualUsed: (map['casualUsed'] as num?)?.toInt() ?? 0,
      sickTotal: (map['sickTotal'] as num?)?.toInt() ?? AppConstants.defaultSickLeave,
      sickUsed: (map['sickUsed'] as num?)?.toInt() ?? 0,
      earnedTotal: (map['earnedTotal'] as num?)?.toInt() ?? AppConstants.defaultEarnedLeave,
      earnedUsed: (map['earnedUsed'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'casualTotal': casualTotal,
      'casualUsed': casualUsed,
      'sickTotal': sickTotal,
      'sickUsed': sickUsed,
      'earnedTotal': earnedTotal,
      'earnedUsed': earnedUsed,
    };
  }

  String toJson() => json.encode(toMap());

  factory LeaveBalanceModel.fromJson(String source) =>
      LeaveBalanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

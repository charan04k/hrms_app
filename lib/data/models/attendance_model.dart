import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.date,
    super.clockInTime,
    super.clockOutTime,
    required super.status,
    super.totalWorkingMinutes = 0,
    super.notes,
  });

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      id: entity.id,
      date: entity.date,
      clockInTime: entity.clockInTime,
      clockOutTime: entity.clockOutTime,
      status: entity.status,
      totalWorkingMinutes: entity.totalWorkingMinutes,
      notes: entity.notes,
    );
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      clockInTime: map['clockInTime'] != null
          ? DateTime.parse(map['clockInTime'] as String)
          : null,
      clockOutTime: map['clockOutTime'] != null
          ? DateTime.parse(map['clockOutTime'] as String)
          : null,
      status: AttendanceStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      totalWorkingMinutes: (map['totalWorkingMinutes'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'clockInTime': clockInTime?.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
      'status': status.name,
      'totalWorkingMinutes': totalWorkingMinutes,
      'notes': notes,
    };
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

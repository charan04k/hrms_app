import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final AttendanceStatus status;
  final int totalWorkingMinutes;
  final String? notes;

  const AttendanceEntity({
    required this.id,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.status,
    this.totalWorkingMinutes = 0,
    this.notes,
  });

  bool get isClockedIn => clockInTime != null && clockOutTime == null;
  bool get isCompleted => clockInTime != null && clockOutTime != null;
  Duration get workingDuration => Duration(minutes: totalWorkingMinutes);

  AttendanceEntity copyWith({
    String? id,
    DateTime? date,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    AttendanceStatus? status,
    int? totalWorkingMinutes,
    String? notes,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      status: status ?? this.status,
      totalWorkingMinutes: totalWorkingMinutes ?? this.totalWorkingMinutes,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        clockInTime,
        clockOutTime,
        status,
        totalWorkingMinutes,
        notes,
      ];
}

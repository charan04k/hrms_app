import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayAttendance extends AttendanceEvent {
  const LoadTodayAttendance();
}

class ClockInRequested extends AttendanceEvent {
  const ClockInRequested();
}

class ClockOutRequested extends AttendanceEvent {
  const ClockOutRequested();

}

class LoadAttendanceHistory extends AttendanceEvent {
  final int year;
  final int month;

  const LoadAttendanceHistory({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

class ChangeAttendanceMonth extends AttendanceEvent {
  final int year;
  final int month;

  const ChangeAttendanceMonth({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

class FilterAttendanceStatusChanged extends AttendanceEvent {
  final AttendanceStatus? status;

  const FilterAttendanceStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}



class AttendanceTimerTick extends AttendanceEvent {
  const AttendanceTimerTick();
}

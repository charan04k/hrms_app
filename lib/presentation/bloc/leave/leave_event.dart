import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaveData extends LeaveEvent {
  const LoadLeaveData();
}

class ApplyLeaveSubmitted extends LeaveEvent {
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  const ApplyLeaveSubmitted({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  @override
  List<Object?> get props => [leaveType, startDate, endDate, reason];
}

class UpdateLeaveStatusSubmitted extends LeaveEvent {
  final String requestId;
  final LeaveStatus newStatus;
  final String? reviewNote;

  const UpdateLeaveStatusSubmitted({
    required this.requestId,
    required this.newStatus,
    this.reviewNote,
  });

  @override
  List<Object?> get props => [requestId, newStatus, reviewNote];
}

class FilterLeaveStatusChanged extends LeaveEvent {
  final LeaveStatus? status;

  const FilterLeaveStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchLeaveQueryChanged extends LeaveEvent {
  final String query;

  const SearchLeaveQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterLeaveDateRangeChanged extends LeaveEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterLeaveDateRangeChanged({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

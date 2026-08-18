import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/attendance_entity.dart';

enum AttendanceActionStatus { initial, loading, success, failure }

class AttendanceState extends Equatable {
  final AttendanceEntity? todayAttendance;
  final bool isClockedIn;
  final Duration elapsedWorkingDuration;
  final List<AttendanceEntity> monthlyHistory;
  final List<AttendanceEntity> filteredHistory;
  final int selectedYear;
  final int selectedMonth;
  final AttendanceStatus? selectedStatusFilter;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool isLoading;
  final AttendanceActionStatus actionStatus;
  final String? successMessage;
  final String? errorMessage;

  const AttendanceState({
    this.todayAttendance,
    this.isClockedIn = false,
    this.elapsedWorkingDuration = Duration.zero,
    this.monthlyHistory = const [],
    this.filteredHistory = const [],
    required this.selectedYear,
    required this.selectedMonth,
    this.selectedStatusFilter,
    this.filterStartDate,
    this.filterEndDate,
    this.isLoading = false,
    this.actionStatus = AttendanceActionStatus.initial,
    this.successMessage,
    this.errorMessage,
  });

  factory AttendanceState.initial() {
    final now = DateTime.now();
    return AttendanceState(
      selectedYear: now.year,
      selectedMonth: now.month,
    );
  }

  // Computed metrics
  int get presentCount =>
      monthlyHistory.where((a) => a.status == AttendanceStatus.present).length;
  int get absentCount =>
      monthlyHistory.where((a) => a.status == AttendanceStatus.absent).length;
  int get onLeaveCount =>
      monthlyHistory.where((a) => a.status == AttendanceStatus.onLeave).length;
  int get holidayCount =>
      monthlyHistory.where((a) => a.status == AttendanceStatus.holiday).length;
  int get totalWorkingMinutes => monthlyHistory
      .where((a) => a.status == AttendanceStatus.present)
      .fold<int>(0, (sum, a) => sum + a.totalWorkingMinutes);

  AttendanceState copyWith({
    AttendanceEntity? todayAttendance,
    bool? isClockedIn,
    Duration? elapsedWorkingDuration,
    List<AttendanceEntity>? monthlyHistory,
    List<AttendanceEntity>? filteredHistory,
    int? selectedYear,
    int? selectedMonth,
    AttendanceStatus? selectedStatusFilter,
    bool clearStatusFilter = false,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearDateRangeFilter = false,
    bool? isLoading,
    AttendanceActionStatus? actionStatus,
    String? successMessage,
    String? errorMessage,
  }) {
    return AttendanceState(
      todayAttendance: todayAttendance ?? this.todayAttendance,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      elapsedWorkingDuration: elapsedWorkingDuration ?? this.elapsedWorkingDuration,
      monthlyHistory: monthlyHistory ?? this.monthlyHistory,
      filteredHistory: filteredHistory ?? this.filteredHistory,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedStatusFilter: clearStatusFilter
          ? null
          : (selectedStatusFilter ?? this.selectedStatusFilter),
      filterStartDate: clearDateRangeFilter
          ? null
          : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearDateRangeFilter
          ? null
          : (filterEndDate ?? this.filterEndDate),
      isLoading: isLoading ?? this.isLoading,
      actionStatus: actionStatus ?? this.actionStatus,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        todayAttendance,
        isClockedIn,
        elapsedWorkingDuration,
        monthlyHistory,
        filteredHistory,
        selectedYear,
        selectedMonth,
        selectedStatusFilter,
        filterStartDate,
        filterEndDate,
        isLoading,
        actionStatus,
        successMessage,
        errorMessage,
      ];
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../domain/entities/attendance_entity.dart';
import '../../../domain/usecases/attendance/clock_in_usecase.dart';
import '../../../domain/usecases/attendance/clock_out_usecase.dart';
import '../../../domain/usecases/attendance/get_attendance_history_usecase.dart';
import '../../../domain/usecases/attendance/get_today_attendance_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetTodayAttendanceUseCase getTodayAttendanceUseCase;
  final ClockInUseCase clockInUseCase;
  final ClockOutUseCase clockOutUseCase;
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;

  Timer? _tickerTimer;

  AttendanceBloc({
    required this.getTodayAttendanceUseCase,
    required this.clockInUseCase,
    required this.clockOutUseCase,
    required this.getAttendanceHistoryUseCase,
  }) : super(AttendanceState.initial()) {
    on<LoadTodayAttendance>(_onLoadTodayAttendance);
    on<ClockInRequested>(_onClockInRequested);
    on<ClockOutRequested>(_onClockOutRequested);
    on<LoadAttendanceHistory>(_onLoadAttendanceHistory);
    on<ChangeAttendanceMonth>(_onChangeAttendanceMonth);
    on<FilterAttendanceStatusChanged>(_onFilterAttendanceStatusChanged);
    // on<FilterAttendanceDateRangeChanged>(_onFilterAttendanceDateRangeChanged);
    on<AttendanceTimerTick>(_onAttendanceTimerTick);

    _startTicker();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const AttendanceTimerTick());
    });
  }

  void _onAttendanceTimerTick(
      AttendanceTimerTick event,
      Emitter<AttendanceState> emit,
      ) {
    if (state.todayAttendance != null && state.todayAttendance!.isClockedIn) {
      final clockIn = state.todayAttendance!.clockInTime!;
      final elapsed = DateTime.now().difference(clockIn);
      emit(state.copyWith(
        isClockedIn: true,
        elapsedWorkingDuration: elapsed,
      ));
    }
  }

  Future<void> _onLoadTodayAttendance(
      LoadTodayAttendance event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final today = await getTodayAttendanceUseCase();
      final history = await getAttendanceHistoryUseCase(
        state.selectedYear,
        state.selectedMonth,
      );

      Duration elapsed = Duration.zero;
      bool clockedIn = false;

      if (today != null) {
        if (today.isClockedIn) {
          clockedIn = true;
          elapsed = DateTime.now().difference(today.clockInTime!);
        } else if (today.isCompleted) {
          elapsed = Duration(minutes: today.totalWorkingMinutes);
        }
      }

      final filtered = _applyFilters(
        history,
        state.selectedStatusFilter,
        state.filterStartDate,
        state.filterEndDate,
      );

      emit(state.copyWith(
        isLoading: false,
        todayAttendance: today,
        isClockedIn: clockedIn,
        elapsedWorkingDuration: elapsed,
        monthlyHistory: history,
        filteredHistory: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onClockInRequested(
      ClockInRequested event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(actionStatus: AttendanceActionStatus.loading));
    try {
      final attendance = await clockInUseCase();
      final history = await getAttendanceHistoryUseCase(
        state.selectedYear,
        state.selectedMonth,
      );

      final filtered = _applyFilters(
        history,
        state.selectedStatusFilter,
        state.filterStartDate,
        state.filterEndDate,
      );

      emit(state.copyWith(
        actionStatus: AttendanceActionStatus.success,
        successMessage: 'Clocked In Successfully at ${DateTimeUtils.formatTime(attendance.clockInTime!)}',
        todayAttendance: attendance,
        isClockedIn: true,
        elapsedWorkingDuration: Duration.zero,
        monthlyHistory: history,
        filteredHistory: filtered,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        actionStatus: AttendanceActionStatus.failure,
        errorMessage: f.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AttendanceActionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onClockOutRequested(
      ClockOutRequested event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(actionStatus: AttendanceActionStatus.loading));
    try {
      final attendance = await clockOutUseCase();
      final history = await getAttendanceHistoryUseCase(
        state.selectedYear,
        state.selectedMonth,
      );

      final filtered = _applyFilters(
        history,
        state.selectedStatusFilter,
        state.filterStartDate,
        state.filterEndDate,
      );

      emit(state.copyWith(
        actionStatus: AttendanceActionStatus.success,
        successMessage: 'Clocked Out Successfully. Worked ${DateTimeUtils.formatDuration(Duration(minutes: attendance.totalWorkingMinutes))}',
        todayAttendance: attendance,
        isClockedIn: false,
        elapsedWorkingDuration: Duration(minutes: attendance.totalWorkingMinutes),
        monthlyHistory: history,
        filteredHistory: filtered,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        actionStatus: AttendanceActionStatus.failure,
        errorMessage: f.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AttendanceActionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAttendanceHistory(
      LoadAttendanceHistory event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final history = await getAttendanceHistoryUseCase(event.year, event.month);
      final filtered = _applyFilters(
        history,
        state.selectedStatusFilter,
        state.filterStartDate,
        state.filterEndDate,
      );

      emit(state.copyWith(
        isLoading: false,
        selectedYear: event.year,
        selectedMonth: event.month,
        monthlyHistory: history,
        filteredHistory: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeAttendanceMonth(
      ChangeAttendanceMonth event,
      Emitter<AttendanceState> emit,
      ) async {
    add(LoadAttendanceHistory(year: event.year, month: event.month));
  }

  void _onFilterAttendanceStatusChanged(
      FilterAttendanceStatusChanged event,
      Emitter<AttendanceState> emit,
      ) {
    final filtered = _applyFilters(
      state.monthlyHistory,
      event.status,
      state.filterStartDate,
      state.filterEndDate,
    );

    emit(state.copyWith(
      selectedStatusFilter: event.status,
      clearStatusFilter: event.status == null,
      filteredHistory: filtered,
    ));
  }


  List<AttendanceEntity> _applyFilters(
      List<AttendanceEntity> list,
      AttendanceStatus? status,
      DateTime? startDate,
      DateTime? endDate,
      ) {
    return list.where((item) {
      // Filter by status
      if (status != null && item.status != status) {
        return false;
      }
      // Filter by date range
      if (startDate != null && endDate != null) {
        if (!DateTimeUtils.isDateInRange(item.date, startDate, endDate)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    return super.close();
  }
}

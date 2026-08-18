import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../domain/entities/leave_request_entity.dart';
import '../../../domain/usecases/leave/apply_leave_usecase.dart';
import '../../../domain/usecases/leave/get_leave_balances_usecase.dart';
import '../../../domain/usecases/leave/get_leave_requests_usecase.dart';
import '../../../domain/usecases/leave/update_leave_status_usecase.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final GetLeaveBalancesUseCase getLeaveBalancesUseCase;
  final GetLeaveRequestsUseCase getLeaveRequestsUseCase;
  final ApplyLeaveUseCase applyLeaveUseCase;
  final UpdateLeaveStatusUseCase updateLeaveStatusUseCase;

  LeaveBloc({
    required this.getLeaveBalancesUseCase,
    required this.getLeaveRequestsUseCase,
    required this.applyLeaveUseCase,
    required this.updateLeaveStatusUseCase,
  }) : super(LeaveState.initial()) {
    on<LoadLeaveData>(_onLoadLeaveData);
    on<ApplyLeaveSubmitted>(_onApplyLeaveSubmitted);
    on<UpdateLeaveStatusSubmitted>(_onUpdateLeaveStatusSubmitted);
    on<FilterLeaveStatusChanged>(_onFilterLeaveStatusChanged);
    on<SearchLeaveQueryChanged>(_onSearchLeaveQueryChanged);
    on<FilterLeaveDateRangeChanged>(_onFilterLeaveDateRangeChanged);
  }

  Future<void> _onLoadLeaveData(
    LoadLeaveData event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final balance = await getLeaveBalancesUseCase();
      final requests = await getLeaveRequestsUseCase();

      final filtered = _applyFilters(
        requests,
        state.selectedStatusFilter,
        state.searchQuery,
        state.filterStartDate,
        state.filterEndDate,
      );

      emit(state.copyWith(
        isLoading: false,
        leaveBalance: balance,
        allRequests: requests,
        filteredRequests: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onApplyLeaveSubmitted(
    ApplyLeaveSubmitted event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(actionStatus: LeaveActionStatus.loading));
    try {
      await applyLeaveUseCase(
        leaveType: event.leaveType,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
      );

      final balance = await getLeaveBalancesUseCase();
      final requests = await getLeaveRequestsUseCase();

      final filtered = _applyFilters(
        requests,
        state.selectedStatusFilter,
        state.searchQuery,
        state.filterStartDate,
        state.filterEndDate,
      );

      emit(state.copyWith(
        actionStatus: LeaveActionStatus.success,
        successMessage: 'Leave application submitted successfully!',
        leaveBalance: balance,
        allRequests: requests,
        filteredRequests: filtered,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        actionStatus: LeaveActionStatus.failure,
        errorMessage: f.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: LeaveActionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateLeaveStatusSubmitted(
    UpdateLeaveStatusSubmitted event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(actionStatus: LeaveActionStatus.loading));
    try {
      await updateLeaveStatusUseCase(
        requestId: event.requestId,
        newStatus: event.newStatus,
        reviewNote: event.reviewNote,
      );

      final balance = await getLeaveBalancesUseCase();
      final requests = await getLeaveRequestsUseCase();

      final filtered = _applyFilters(
        requests,
        state.selectedStatusFilter,
        state.searchQuery,
        state.filterStartDate,
        state.filterEndDate,
      );

      final actionStr = event.newStatus == LeaveStatus.approved ? 'Approved' : 'Rejected';

      emit(state.copyWith(
        actionStatus: LeaveActionStatus.success,
        successMessage: 'Leave request was successfully $actionStr. Balances updated!',
        leaveBalance: balance,
        allRequests: requests,
        filteredRequests: filtered,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        actionStatus: LeaveActionStatus.failure,
        errorMessage: f.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: LeaveActionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFilterLeaveStatusChanged(
    FilterLeaveStatusChanged event,
    Emitter<LeaveState> emit,
  ) {
    final filtered = _applyFilters(
      state.allRequests,
      event.status,
      state.searchQuery,
      state.filterStartDate,
      state.filterEndDate,
    );

    emit(state.copyWith(
      selectedStatusFilter: event.status,
      clearStatusFilter: event.status == null,
      filteredRequests: filtered,
    ));
  }

  void _onSearchLeaveQueryChanged(
    SearchLeaveQueryChanged event,
    Emitter<LeaveState> emit,
  ) {
    final filtered = _applyFilters(
      state.allRequests,
      state.selectedStatusFilter,
      event.query,
      state.filterStartDate,
      state.filterEndDate,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredRequests: filtered,
    ));
  }

  void _onFilterLeaveDateRangeChanged(
    FilterLeaveDateRangeChanged event,
    Emitter<LeaveState> emit,
  ) {
    final isClearing = event.startDate == null && event.endDate == null;
    final filtered = _applyFilters(
      state.allRequests,
      state.selectedStatusFilter,
      state.searchQuery,
      event.startDate,
      event.endDate,
    );

    emit(state.copyWith(
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
      clearDateRangeFilter: isClearing,
      filteredRequests: filtered,
    ));
  }

  List<LeaveRequestEntity> _applyFilters(
    List<LeaveRequestEntity> list,
    LeaveStatus? status,
    String query,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return list.where((req) {
      if (status != null && req.status != status) {
        return false;
      }

      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchReason = req.reason.toLowerCase().contains(q);
        final matchType = req.leaveType.name.toLowerCase().contains(q);
        if (!matchReason && !matchType) {
          return false;
        }
      }

      if (startDate != null && endDate != null) {
        if (!DateTimeUtils.doesOverlap(startDate, endDate, req.startDate, req.endDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/leave_balance_entity.dart';
import '../../../domain/entities/leave_request_entity.dart';

enum LeaveActionStatus { initial, loading, success, failure }

class LeaveState extends Equatable {
  final LeaveBalanceEntity leaveBalance;
  final List<LeaveRequestEntity> allRequests;
  final List<LeaveRequestEntity> filteredRequests;
  final LeaveStatus? selectedStatusFilter;
  final String searchQuery;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool isLoading;
  final LeaveActionStatus actionStatus;
  final String? successMessage;
  final String? errorMessage;

  const LeaveState({
    this.leaveBalance = const LeaveBalanceEntity(),
    this.allRequests = const [],
    this.filteredRequests = const [],
    this.selectedStatusFilter,
    this.searchQuery = '',
    this.filterStartDate,
    this.filterEndDate,
    this.isLoading = false,
    this.actionStatus = LeaveActionStatus.initial,
    this.successMessage,
    this.errorMessage,
  });

  factory LeaveState.initial() => const LeaveState();

  // Computed counters
  int get pendingCount =>
      allRequests.where((r) => r.status == LeaveStatus.pending).length;
  int get approvedCount =>
      allRequests.where((r) => r.status == LeaveStatus.approved).length;
  int get rejectedCount =>
      allRequests.where((r) => r.status == LeaveStatus.rejected).length;

  LeaveState copyWith({
    LeaveBalanceEntity? leaveBalance,
    List<LeaveRequestEntity>? allRequests,
    List<LeaveRequestEntity>? filteredRequests,
    LeaveStatus? selectedStatusFilter,
    bool clearStatusFilter = false,
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearDateRangeFilter = false,
    bool? isLoading,
    LeaveActionStatus? actionStatus,
    String? successMessage,
    String? errorMessage,
  }) {
    return LeaveState(
      leaveBalance: leaveBalance ?? this.leaveBalance,
      allRequests: allRequests ?? this.allRequests,
      filteredRequests: filteredRequests ?? this.filteredRequests,
      selectedStatusFilter: clearStatusFilter
          ? null
          : (selectedStatusFilter ?? this.selectedStatusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
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
        leaveBalance,
        allRequests,
        filteredRequests,
        selectedStatusFilter,
        searchQuery,
        filterStartDate,
        filterEndDate,
        isLoading,
        actionStatus,
        successMessage,
        errorMessage,
      ];
}

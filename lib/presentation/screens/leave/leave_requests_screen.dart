import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../domain/entities/leave_request_entity.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/attendance/attendance_event.dart';
import '../../bloc/leave/leave_bloc.dart';
import '../../bloc/leave/leave_event.dart';
import '../../bloc/leave/leave_state.dart';

import '../widget/empty_state_widget.dart';
import '../widget/leave_detail_sheet.dart';
import '../widget/status_badge.dart';
import 'apply_leave_screen.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final state = context.read<LeaveBloc>().state;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: state.filterStartDate != null && state.filterEndDate != null
          ? DateTimeRange(start: state.filterStartDate!, end: state.filterEndDate!)
          : null,
    );

    if (!mounted) return;

    if (picked != null) {
      context.read<LeaveBloc>().add(
            FilterLeaveDateRangeChanged(
              startDate: picked.start,
              endDate: picked.end,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Leave Requests'),
        actions: [
          IconButton(
            tooltip: 'Filter by Date Range',
            icon: const Icon(Icons.date_range_rounded, color: AppColors.textSecondary),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ApplyLeaveScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Apply Leave', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == LeaveActionStatus.success &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.present,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Also refresh attendance history if an approval happened
            context.read<AttendanceBloc>().add(const LoadTodayAttendance());
          } else if (state.actionStatus == LeaveActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.absent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<LeaveBloc>().add(const LoadLeaveData());
            },
            child: Column(
              children: [
                // Top Search & Filters Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          context.read<LeaveBloc>().add(SearchLeaveQueryChanged(val));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by reason or leave type...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<LeaveBloc>()
                                        .add(const SearchLeaveQueryChanged(''));
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Tab Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatusTabChip(
                              label: 'All (${state.allRequests.length})',
                              isSelected: state.selectedStatusFilter == null,
                              onTap: () {
                                context.read<LeaveBloc>().add(
                                      const FilterLeaveStatusChanged(null),
                                    );
                              },
                            ),
                            const SizedBox(width: 8),
                            _StatusTabChip(
                              label: 'Pending (${state.pendingCount})',
                              isSelected: state.selectedStatusFilter == LeaveStatus.pending,
                              color: AppColors.pending,
                              onTap: () {
                                context.read<LeaveBloc>().add(
                                      const FilterLeaveStatusChanged(LeaveStatus.pending),
                                    );
                              },
                            ),
                            const SizedBox(width: 8),
                            _StatusTabChip(
                              label: 'Approved (${state.approvedCount})',
                              isSelected: state.selectedStatusFilter == LeaveStatus.approved,
                              color: AppColors.approved,
                              onTap: () {
                                context.read<LeaveBloc>().add(
                                      const FilterLeaveStatusChanged(LeaveStatus.approved),
                                    );
                              },
                            ),
                            const SizedBox(width: 8),
                            _StatusTabChip(
                              label: 'Rejected (${state.rejectedCount})',
                              isSelected: state.selectedStatusFilter == LeaveStatus.rejected,
                              color: AppColors.rejected,
                              onTap: () {
                                context.read<LeaveBloc>().add(
                                      const FilterLeaveStatusChanged(LeaveStatus.rejected),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Date Range Filter Banner (if any)
                if (state.filterStartDate != null && state.filterEndDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.primary.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Date Filter: ${DateTimeUtils.formatDate(state.filterStartDate!)} - ${DateTimeUtils.formatDate(state.filterEndDate!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            context.read<LeaveBloc>().add(
                                  const FilterLeaveDateRangeChanged(
                                    startDate: null,
                                    endDate: null,
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),

                // Leave Requests List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.filteredRequests.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.event_note_rounded,
                              title: 'No Leave Requests Found',
                              message: 'No requests match your current search or status filter.',
                              actionLabel: 'Apply for Leave',
                              onAction: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ApplyLeaveScreen(),
                                  ),
                                );
                              },
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                              itemCount: state.filteredRequests.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final req = state.filteredRequests[index];
                                return _LeaveRequestCard(
                                  request: req,
                                  onTap: () {
                                    LeaveDetailSheet.show(
                                      context,
                                      request: req,
                                      onUpdateStatus: (id, status, note) {
                                        context.read<LeaveBloc>().add(
                                              UpdateLeaveStatusSubmitted(
                                                requestId: id,
                                                newStatus: status,
                                                reviewNote: note,
                                              ),
                                            );
                                      },
                                    );
                                  },
                                  onApprove: () {
                                    context.read<LeaveBloc>().add(
                                          UpdateLeaveStatusSubmitted(
                                            requestId: req.id,
                                            newStatus: LeaveStatus.approved,
                                            reviewNote: 'Quick-approved via Demo Mode',
                                          ),
                                        );
                                  },
                                  onReject: () {
                                    context.read<LeaveBloc>().add(
                                          UpdateLeaveStatusSubmitted(
                                            requestId: req.id,
                                            newStatus: LeaveStatus.rejected,
                                            reviewNote: 'Quick-rejected via Demo Mode',
                                          ),
                                        );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequestEntity request;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LeaveRequestCard({
    required this.request,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Type & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LeaveTypeBadge(type: request.leaveType),
                LeaveStatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 12),

            // Date Range & Duration
            Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${DateTimeUtils.formatDate(request.startDate)} - ${DateTimeUtils.formatDate(request.endDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${request.totalDays} Day${request.totalDays > 1 ? "s" : ""}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reason
            Text(
              request.reason,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            const Divider(),
            const SizedBox(height: 6),

            // Footer row: Applied timestamp & Quick Simulation actions if pending
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied: ${DateTimeUtils.formatDate(request.appliedAt)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                if (request.status == LeaveStatus.pending)
                  Row(
                    children: [
                      InkWell(
                        onTap: onApprove,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.presentBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.presentBorder),
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.present,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onReject,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.absentBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.absentBorder),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.absent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const Row(
                    children: [
                      Text(
                        'Tap for details',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _StatusTabChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

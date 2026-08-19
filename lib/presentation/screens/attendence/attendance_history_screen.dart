import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../bloc/attendance/attendance_event.dart';
import '../../bloc/attendance/attendance_state.dart';
import '../widget/empty_state_widget.dart';
import '../widget/stat_summary_card.dart';
import '../widget/status_badge.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {

  void _previousMonth(int year, int month) {
    int newMonth = month - 1;
    int newYear = year;
    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }
    context.read<AttendanceBloc>().add(
          ChangeAttendanceMonth(year: newYear, month: newMonth),
        );
  }

  void _nextMonth(int year, int month) {
    int newMonth = month + 1;
    int newYear = year;
    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }
    context.read<AttendanceBloc>().add(
          ChangeAttendanceMonth(year: newYear, month: newMonth),
        );
  }

  Future<void> _pickDateRange() async {
    final state = context.read<AttendanceBloc>().state;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: state.filterStartDate != null && state.filterEndDate != null
          ? DateTimeRange(start: state.filterStartDate!, end: state.filterEndDate!)
          : null,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (picked != null) {
      context.read<AttendanceBloc>().add(
            FilterAttendanceDateRangeChanged(
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
        title: const Text('Attendance History'),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          final currentDisplayDate = DateTime(state.selectedYear, state.selectedMonth);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AttendanceBloc>().add(
                    LoadAttendanceHistory(
                      year: state.selectedYear,
                      month: state.selectedMonth,
                    ),
                  );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Navigator Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => _previousMonth(
                            state.selectedYear,
                            state.selectedMonth,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateTimeUtils.formatMonthYear(currentDisplayDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () => _nextMonth(
                            state.selectedYear,
                            state.selectedMonth,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Monthly Metrics Summary
                  Row(
                    children: [
                      Expanded(
                        child: StatSummaryCard(
                          title: 'Present',
                          value: '${state.presentCount}',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.present,
                          backgroundColor: AppColors.presentBg,
                          onTap: () {
                            context.read<AttendanceBloc>().add(
                                  const FilterAttendanceStatusChanged(
                                    AttendanceStatus.present,
                                  ),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatSummaryCard(
                          title: 'Absent',
                          value: '${state.absentCount}',
                          icon: Icons.cancel_outlined,
                          color: AppColors.absent,
                          backgroundColor: AppColors.absentBg,
                          onTap: () {
                            context.read<AttendanceBloc>().add(
                                  const FilterAttendanceStatusChanged(
                                    AttendanceStatus.absent,
                                  ),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatSummaryCard(
                          title: 'On Leave',
                          value: '${state.onLeaveCount}',
                          icon: Icons.beach_access_rounded,
                          color: AppColors.onLeave,
                          backgroundColor: AppColors.onLeaveBg,
                          onTap: () {
                            context.read<AttendanceBloc>().add(
                                  const FilterAttendanceStatusChanged(
                                    AttendanceStatus.onLeave,
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Active Date Range Filter Banner (if any)
                  if (state.filterStartDate != null && state.filterEndDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
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
                              context.read<AttendanceBloc>().add(
                                    const FilterAttendanceDateRangeChanged(
                                      startDate: null,
                                      endDate: null,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 16),

                    if (state.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state.filteredHistory.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.event_busy_rounded,
                        title: 'No Records Found',
                        message: 'No attendance entries matched the selected filters.',
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          context.read<AttendanceBloc>().add(
                                const FilterAttendanceStatusChanged(null),
                              );
                          context.read<AttendanceBloc>().add(
                                const FilterAttendanceDateRangeChanged(
                                  startDate: null,
                                  endDate: null,
                                ),
                              );
                        },
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.filteredHistory.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.filteredHistory[index];
                          return _AttendanceListItem(item: item);
                        },
                      ),
                  ],

                  // const SizedBox(height: 24),

              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttendanceListItem extends StatelessWidget {
  final dynamic item;

  const _AttendanceListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Date Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${item.date.day}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateTimeUtils.formatShortMonth(item.date).split(' ').first,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeUtils.formatDateFull(item.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.clockInTime != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${DateTimeUtils.formatTime(item.clockInTime!)} - ${item.clockOutTime != null ? DateTimeUtils.formatTime(item.clockOutTime!) : "Present"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${DateTimeUtils.formatDuration(Duration(minutes: item.totalWorkingMinutes))}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    item.notes ?? 'Off Day',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Status Badge
          AttendanceStatusBadge(status: item.status),
        ],
      ),
    );
  }
}



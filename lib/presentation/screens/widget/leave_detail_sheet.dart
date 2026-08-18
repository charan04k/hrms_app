import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../domain/entities/leave_request_entity.dart';

import 'status_badge.dart';

class LeaveDetailSheet extends StatefulWidget {
  final LeaveRequestEntity request;
  final Function(String id, LeaveStatus newStatus, String? note) onUpdateStatus;

  const LeaveDetailSheet({
    super.key,
    required this.request,
    required this.onUpdateStatus,
  });

  static void show(
    BuildContext context, {
    required LeaveRequestEntity request,
    required Function(String id, LeaveStatus newStatus, String? note) onUpdateStatus,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LeaveDetailSheet(
        request: request,
        onUpdateStatus: onUpdateStatus,
      ),
    );
  }

  @override
  State<LeaveDetailSheet> createState() => _LeaveDetailSheetState();
}

class _LeaveDetailSheetState extends State<LeaveDetailSheet> {
  final _adminNoteController = TextEditingController();

  @override
  void dispose() {
    _adminNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Leave Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'ID: ${req.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                LeaveStatusBadge(status: req.status),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Leave Info Grid
            _DetailRow(
              icon: Icons.category_rounded,
              label: 'Leave Type',
              valueWidget: LeaveTypeBadge(type: req.leaveType),
            ),
            const SizedBox(height: 14),

            _DetailRow(
              icon: Icons.date_range_rounded,
              label: 'Dates',
              value: '${DateTimeUtils.formatDate(req.startDate)} - ${DateTimeUtils.formatDate(req.endDate)} (${req.totalDays} day${req.totalDays > 1 ? "s" : ""})',
            ),
            const SizedBox(height: 14),

            _DetailRow(
              icon: Icons.history_rounded,
              label: 'Applied On',
              value: DateTimeUtils.formatDateFull(req.appliedAt),
            ),
            const SizedBox(height: 14),

            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Reason',
              value: req.reason,
            ),

            if (req.reviewNote != null && req.reviewNote!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _DetailRow(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin Remark',
                value: req.reviewNote!,
              ),
            ],

            const SizedBox(height: 24),

            // Admin Demo Simulation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Admin Simulation (Demo)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simulate manager review. Approving will automatically deduct leave days from balance and update attendance records.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _adminNoteController,
                    decoration: const InputDecoration(
                      hintText: 'Optional admin remark / notes...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      if (req.status != LeaveStatus.approved)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onUpdateStatus(
                                req.id,
                                LeaveStatus.approved,
                                _adminNoteController.text.trim().isNotEmpty
                                    ? _adminNoteController.text.trim()
                                    : 'Approved by Manager',
                              );
                            },
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.approved,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (req.status != LeaveStatus.approved && req.status != LeaveStatus.rejected)
                        const SizedBox(width: 12),
                      if (req.status != LeaveStatus.rejected)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onUpdateStatus(
                                req.id,
                                LeaveStatus.rejected,
                                _adminNoteController.text.trim().isNotEmpty
                                    ? _adminNoteController.text.trim()
                                    : 'Rejected due to project deadlines',
                              );
                            },
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.rejected),
                            label: const Text('Reject', style: TextStyle(color: AppColors.rejected)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.rejectedBorder),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        ),
      ],
    );
  }
}

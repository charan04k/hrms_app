import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';



class AttendanceStatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const AttendanceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case AttendanceStatus.present:
        bg = AppColors.presentBg;
        border = AppColors.presentBorder;
        textColor = AppColors.present;
        label = 'Present';
        icon = Icons.check_circle_rounded;
        break;
      case AttendanceStatus.absent:
        bg = AppColors.absentBg;
        border = AppColors.absentBorder;
        textColor = AppColors.absent;
        label = 'Absent';
        icon = Icons.cancel_rounded;
        break;
      case AttendanceStatus.onLeave:
        bg = AppColors.onLeaveBg;
        border = AppColors.onLeaveBorder;
        textColor = AppColors.onLeave;
        label = 'On Leave';
        icon = Icons.beach_access_rounded;
        break;
      case AttendanceStatus.holiday:
        bg = AppColors.holidayBg;
        border = AppColors.holidayBorder;
        textColor = AppColors.holiday;
        label = 'Holiday / Off';
        icon = Icons.event_available_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveStatusBadge extends StatelessWidget {
  final LeaveStatus status;

  const LeaveStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case LeaveStatus.pending:
        bg = AppColors.pendingBg;
        border = AppColors.pendingBorder;
        textColor = AppColors.pending;
        label = 'Pending';
        icon = Icons.hourglass_top_rounded;
        break;
      case LeaveStatus.approved:
        bg = AppColors.approvedBg;
        border = AppColors.approvedBorder;
        textColor = AppColors.approved;
        label = 'Approved';
        icon = Icons.check_circle_rounded;
        break;
      case LeaveStatus.rejected:
        bg = AppColors.rejectedBg;
        border = AppColors.rejectedBorder;
        textColor = AppColors.rejected;
        label = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveTypeBadge extends StatelessWidget {
  final LeaveType type;

  const LeaveTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (type) {
      case LeaveType.casual:
        color = AppColors.casualLeave;
        label = 'Casual Leave';
        break;
      case LeaveType.sick:
        color = AppColors.sickLeave;
        label = 'Sick Leave';
        break;
      case LeaveType.earned:
        color = AppColors.earnedLeave;
        label = 'Earned Leave';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

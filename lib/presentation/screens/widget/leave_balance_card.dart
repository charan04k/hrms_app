import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/leave_balance_entity.dart';


class LeaveBalanceSection extends StatelessWidget {
  final LeaveBalanceEntity balance;
  final Function(LeaveType)? onTypeTap;

  const LeaveBalanceSection({
    super.key,
    required this.balance,
    this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Leave Balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${balance.totalAvailable} Days Total Available',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LeaveTypeCard(
                title: 'Casual Leave',
                available: balance.casualAvailable,
                total: balance.casualTotal,
                color: AppColors.casualLeave,
                icon: Icons.calendar_today_rounded,
                onTap: () => onTypeTap?.call(LeaveType.casual),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LeaveTypeCard(
                title: 'Sick Leave',
                available: balance.sickAvailable,
                total: balance.sickTotal,
                color: AppColors.sickLeave,
                icon: Icons.healing_rounded,
                onTap: () => onTypeTap?.call(LeaveType.sick),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LeaveTypeCard(
                title: 'Earned Leave',
                available: balance.earnedAvailable,
                total: balance.earnedTotal,
                color: AppColors.earnedLeave,
                icon: Icons.workspace_premium_rounded,
                onTap: () => onTypeTap?.call(LeaveType.earned),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeaveTypeCard extends StatelessWidget {
  final String title;
  final int available;
  final int total;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _LeaveTypeCard({
    required this.title,
    required this.available,
    required this.total,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                Text(
                  '$available/$total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$available days left',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

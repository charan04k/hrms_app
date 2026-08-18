import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../domain/entities/attendance_entity.dart';


class ClockStatusCard extends StatefulWidget {
  final AttendanceEntity? attendance;
  final bool isClockedIn;
  final Duration elapsedDuration;
  final bool isLoading;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;

  const ClockStatusCard({
    super.key,
    required this.attendance,
    required this.isClockedIn,
    required this.elapsedDuration,
    required this.isLoading,
    required this.onClockIn,
    required this.onClockOut,
  });

  @override
  State<ClockStatusCard> createState() => _ClockStatusCardState();
}

class _ClockStatusCardState extends State<ClockStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final att = widget.attendance;
    final isCompleted = att != null && att.isCompleted;
    final isClockedIn = widget.isClockedIn;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row with Date and Status badge
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time_filled_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Attendance",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateTimeUtils.formatDateFull(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isClockedIn)
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.presentBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.presentBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.present,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Working',
                            style: TextStyle(
                              color: AppColors.present,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Not Clocked In',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Working Timer Display
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Text(
                  isClockedIn
                      ? 'LIVE WORKING HOURS'
                      : (isCompleted ? 'TOTAL HOURS WORKED' : 'HOURS LOGGED TODAY'),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateTimeUtils.formatDuration(
                    widget.elapsedDuration,
                    includeSeconds: isClockedIn,
                  ),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isClockedIn
                        ? AppColors.primary
                        : (isCompleted ? AppColors.present : AppColors.textPrimary),
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                // Timestamps Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TimestampColumn(
                        label: 'Clock In',
                        time: att?.clockInTime != null
                            ? DateTimeUtils.formatTime(att!.clockInTime!)
                            : '--:--',
                        icon: Icons.login_rounded,
                        color: AppColors.present,
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: AppColors.cardBorder,
                      ),
                      _TimestampColumn(
                        label: 'Clock Out',
                        time: att?.clockOutTime != null
                            ? DateTimeUtils.formatTime(att!.clockOutTime!)
                            : '--:--',
                        icon: Icons.logout_rounded,
                        color: AppColors.absent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Clock In / Clock Out Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isClockedIn
                      ? ElevatedButton.icon(
                          onPressed: widget.onClockOut,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Clock Out Shift'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.absent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : isCompleted
                          ? OutlinedButton.icon(
                              onPressed: null, // Double clock-in prevention
                              icon: const Icon(Icons.check_circle_rounded, color: AppColors.present),
                              label: const Text('Shift Completed for Today'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.presentBorder),
                                backgroundColor: AppColors.presentBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: widget.onClockIn,
                              icon: const Icon(Icons.touch_app_rounded),
                              label: const Text('Clock In Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimestampColumn extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimestampColumn({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

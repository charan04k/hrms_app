import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../login/login_screen.dart';
import '../widget/clock_status_card.dart';


class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {

    final String employeeName = AppConstants.demoEmployeeName;
    final String designation = AppConstants.demoDesignation;

    final bool isClockedIn = false;



    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name = state is AuthAuthenticated
                    ? state.user.name
                    : AppConstants.demoEmployeeName;
                final desig = state is AuthAuthenticated
                    ? state.user.designation
                    : AppConstants.demoDesignation;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateTimeUtils.getGreeting()}, $name',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      desig,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ClockStatusCard(
                attendance: null,
                isClockedIn: isClockedIn,
                elapsedDuration: Duration.zero,
                isLoading: false,

                onClockIn: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clock In clicked'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },

                onClockOut: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clock Out clicked'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),



              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Apply Leave',
                      subtitle: 'Submit request',
                      color: AppColors.primary,
                      onTap: () {

                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Attendance',
                      subtitle: 'Monthly records',
                      color: AppColors.onLeave,
                      onTap: () {
                        onNavigateTab?.call(1);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.list_alt_rounded,
                      title: 'My Requests',
                      subtitle: 'Review & Track',
                      color: AppColors.casualLeave,
                      onTap: () {
                        onNavigateTab?.call(2);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =========================
              // RECENT ACTIVITY
              // =========================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  TextButton(
                    onPressed: () {

                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cardBorder,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'No recent attendance activity recorded yet.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from Pulse HRMS?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.absent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}





class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
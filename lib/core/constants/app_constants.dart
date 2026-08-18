enum AttendanceStatus {
  present,
  absent,
  onLeave,
  holiday,
}

enum LeaveType {
  casual,
  sick,
  earned,
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
}


class AppConstants {
  // Static Credentials
  static const String demoEmployeeId = 'emp001';
  static const String demoPassword = 'password123';
  static const String demoEmployeeName = 'Karthick Charan';
  static const String demoDesignation = 'Flutter Developer';
  static const String demoDepartment = 'Mobile Engineering';
  static const String demoEmail = 'kc@gmail.com';

  // Hive Box Names
  static const String userBoxName = 'userBox';
  static const String attendanceBoxName = 'attendanceBox';
  static const String leaveBoxName = 'leaveBox';
  static const String leaveBalanceBoxName = 'leaveBalanceBox';


  // SharedPreferences Keys
  static const String keyCurrentUser = 'currentUser';

  // Leave Default Allocations
  static const int defaultCasualLeave = 12;
  static const int defaultSickLeave = 10;
  static const int defaultEarnedLeave = 15;

}

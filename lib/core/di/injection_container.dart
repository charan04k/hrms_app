import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasource/attendance_local_datasource.dart';
import '../../data/datasource/auth_local_datasource.dart';
import '../../data/datasource/leave_local_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/leave_repository_impl.dart';
import '../../domain/repositories/attendance/attendance_repository.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../../domain/repositories/leave/leave_repository.dart';
import '../../domain/usecases/attendance/clock_in_usecase.dart';
import '../../domain/usecases/attendance/clock_out_usecase.dart';
import '../../domain/usecases/attendance/get_attendance_history_usecase.dart';
import '../../domain/usecases/attendance/get_today_attendance_usecase.dart';
import '../../domain/usecases/leave/apply_leave_usecase.dart';
import '../../domain/usecases/leave/get_leave_balances_usecase.dart';
import '../../domain/usecases/leave/get_leave_requests_usecase.dart';
import '../../domain/usecases/leave/update_leave_status_usecase.dart';
import '../../presentation/bloc/attendance/attendance_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/leave/leave_bloc.dart';
import '../constants/app_constants.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';


final sl = GetIt.instance;

Future<void> initDependencies() async {

//1 Box
  final userBox = await Hive.openBox(AppConstants.userBoxName);
  final attendanceBox = await Hive.openBox(AppConstants.attendanceBoxName);
  final leaveBox = await Hive.openBox(AppConstants.leaveBoxName);
  final leaveBalanceBox = await Hive.openBox(AppConstants.leaveBalanceBoxName);


  // 2. DataSources
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
      userBox: userBox,
    ),
  );

  sl.registerLazySingleton<AttendanceLocalDataSource>(
        () => AttendanceLocalDataSourceImpl(
      attendanceBox: attendanceBox,
    ),
  );

  sl.registerLazySingleton<LeaveRepository>(
        () => LeaveRepositoryImpl(localDataSource: sl()),
  );




  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<LeaveLocalDataSource>(
        () => LeaveLocalDataSourceImpl(
      leaveBox: leaveBox,
      leaveBalanceBox: leaveBalanceBox,
    ),
  );



  // 4. UseCases - Auth
  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(repository: sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(repository: sl()),
  );

  // 4. UseCases - Attendance
  sl.registerLazySingleton<ClockInUseCase>(
        () => ClockInUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ClockOutUseCase>(
        () => ClockOutUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetTodayAttendanceUseCase>(
        () => GetTodayAttendanceUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetAttendanceHistoryUseCase>(
        () => GetAttendanceHistoryUseCase(repository: sl()),
  );

  // 4. UseCases - Leave
  sl.registerLazySingleton<GetLeaveBalancesUseCase>(
        () => GetLeaveBalancesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetLeaveRequestsUseCase>(
        () => GetLeaveRequestsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ApplyLeaveUseCase>(
        () => ApplyLeaveUseCase(repository: sl()),
  );
  sl.registerLazySingleton<UpdateLeaveStatusUseCase>(
        () => UpdateLeaveStatusUseCase(
      leaveRepository: sl(),
      attendanceRepository: sl(),
    ),
  );


  // 5. BLoCs
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory<AttendanceBloc>(
        () => AttendanceBloc(
      getTodayAttendanceUseCase: sl(),
      clockInUseCase: sl(),
      clockOutUseCase: sl(),
      getAttendanceHistoryUseCase: sl(),
    ),
  );

  sl.registerFactory<LeaveBloc>(
        () => LeaveBloc(
      getLeaveBalancesUseCase: sl(),
      getLeaveRequestsUseCase: sl(),
      applyLeaveUseCase: sl(),
      updateLeaveStatusUseCase: sl(),
    ),
  );
  await sl<AttendanceRepository>().seedInitialAttendanceIfEmpty();
  await sl<LeaveRepository>().seedInitialLeavesIfEmpty();
}

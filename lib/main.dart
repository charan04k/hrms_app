import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:hrms_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:hrms_app/presentation/bloc/auth/auth_event.dart';
import 'package:hrms_app/presentation/bloc/auth/auth_state.dart';
import 'package:hrms_app/presentation/bloc/leave/leave_bloc.dart';
import 'package:hrms_app/presentation/screens/login/login_screen.dart';
import 'package:hrms_app/presentation/screens/main_navigation_screen.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize all dependencies (Datasources, Repositories, UseCases, BLoCs, Seed Data)
  await di.initDependencies();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<AttendanceBloc>(
          create: (_) => di.sl<AttendanceBloc>(),
        ),
        BlocProvider<LeaveBloc>(
          create: (_) => di.sl<LeaveBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pulse HRMS',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
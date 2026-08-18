import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasource/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';


final sl = GetIt.instance;

Future<void> initDependencies() async {

//1 Box
  final userBox = await Hive.openBox(AppConstants.userBoxName);


  // 2. DataSources
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
      userBox: userBox,
    ),
  );



  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(localDataSource: sl()),
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


  // 5. BLoCs
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

}

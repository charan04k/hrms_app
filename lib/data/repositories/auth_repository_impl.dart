import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity?> login(String employeeId, String password) {
    return localDataSource.login(employeeId, password);
  }

  @override
  Future<void> logout() {
    return localDataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return localDataSource.getCurrentUser();
  }
}

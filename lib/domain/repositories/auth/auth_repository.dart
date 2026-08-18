import '../../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String employeeId, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}

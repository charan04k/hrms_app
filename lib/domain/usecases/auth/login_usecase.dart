import '../../entities/user_entity.dart';
import '../../repositories/auth/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<UserEntity?> call(String employeeId, String password) {
    return repository.login(employeeId, password);
  }
}

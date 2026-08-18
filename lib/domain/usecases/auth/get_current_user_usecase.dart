import '../../entities/user_entity.dart';
import '../../repositories/auth/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}

import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/respositories/auth_respository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}

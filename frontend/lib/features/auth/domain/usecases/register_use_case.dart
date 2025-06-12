import '../entities/user_entity.dart';
import '../repositories/auth_respository.dart';

class RegisterUseCase{
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<UserEntity> call(String username, String email, String password){
    return repository.register(username, email, password);
  }
}
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_respository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase({required this.repository});

  Future<UserEntity> call() {
    return repository.getUserProfile();
  }
}
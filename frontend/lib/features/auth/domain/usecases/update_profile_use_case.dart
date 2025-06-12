import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_respository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<UserEntity> call({String? fullName, String? bio, DateTime? dob, String? profilePic}) {
    return repository.updateProfile(fullName, bio, dob, profilePic);
  }
}
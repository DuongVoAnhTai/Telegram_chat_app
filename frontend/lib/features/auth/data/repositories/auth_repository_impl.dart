import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_respository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) async {
    // TODO: implement login
    return await authRemoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserEntity> register(
    String fullname,
    String email,
    String password,
  ) async {
    // TODO: implement register
    return await authRemoteDataSource.register(
      fullname: fullname,
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> getUserProfile() async {
    return await authRemoteDataSource.getUserProfile();
  }

  @override
  Future<UserEntity> updateProfile(String? fullname, String? bio, DateTime? dob, String? profilePic) async {
    return await authRemoteDataSource.updateProfile(
      fullname: fullname,
      bio: bio,
      dob: dob,
      profilePic: profilePic,
    );
  }
}

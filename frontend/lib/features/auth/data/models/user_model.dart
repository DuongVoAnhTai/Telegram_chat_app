import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String fullname,
    required String email,
    required String token,
  }) : super(id: id, fullname: fullname, email: email, token: token);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullname: json['fullName'],
      email: json['email'],
      token: json['token'] ?? '',
    );
  }
}

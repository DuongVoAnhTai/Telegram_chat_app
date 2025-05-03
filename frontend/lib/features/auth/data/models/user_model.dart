import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String fullname,
    required String email,
    required String token,
    String profilePic = '',
    String bio = '',
    DateTime? dob,
  }) : super(id: id, fullname: fullname, email: email, token: token, profilePic: profilePic, bio: bio, dob: dob);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullname: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token'] ?? '',
      profilePic: json['profilePic'] ?? '',
      bio: json['bio'] ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullname,
      'email': email,
      'token': token,
      'profilePic': profilePic,
      'bio': bio,
      'dob': dob?.toIso8601String(),
    };
  }
}

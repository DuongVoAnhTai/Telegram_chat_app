abstract class AuthEvent {}

class RegisterEvent extends AuthEvent{
  final String username;
  final String email;
  final String password;

  RegisterEvent({required this.username, required this.email, required this.password,});

}

class LoginEvent extends AuthEvent{
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class GetUserProfileEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? fullname;
  final String? bio;
  final DateTime? dob;
  final String? profilePic;

  UpdateProfileEvent({
    this.fullname,
    this.bio,
    this.dob,
    this.profilePic,
  });
}
class UserEntity {
  final String id;
  final String email;
  final String fullname;
  final String token;

  UserEntity({required this.id, required this.email, required this.fullname, this.token ='',});

}
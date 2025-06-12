class UserEntity {
  final String id;
  final String email;
  final String fullname;
  final String token;
  final String profilePic;
  final String bio;
  final DateTime? dob;

  UserEntity({required this.id, required this.email, required this.fullname, this.token ='', this.profilePic = '', this.bio = '', this.dob});

}
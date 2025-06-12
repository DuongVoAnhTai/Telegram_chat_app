import 'package:frontend/features/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  ContactModel({
    required String id,
    required String name,
    required String email,
    required String userId,
    required String profilePic,
  }) : super(id: id, name: name, email: email, userId: userId, profilePic: profilePic);

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['_id'] as String,
      name: json['contactId']['fullName'] as String,
      email: json['contactId']['email'] as String,
      userId: json['contactId']['_id'],
      profilePic: json['contactId']['profilePic'] as String,
    );
  }
}

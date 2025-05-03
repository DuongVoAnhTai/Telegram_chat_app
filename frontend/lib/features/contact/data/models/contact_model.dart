import 'package:frontend/features/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  ContactModel({
    required String id,
    required String name,
    required String email,
  }) : super(id: id, name: name, email: email);

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['_id'] as String,
      name: json['contactId']['fullName'] as String,
      email: json['contactId']['email'] as String,
    );
  }
}

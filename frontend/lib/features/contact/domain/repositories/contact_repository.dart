import 'package:frontend/features/contact/domain/entities/contact_entity.dart';

abstract class ContactRepository {
  Future<void> addContact({String email});
  Future<List<ContactEntity>> fetchContacts();
  // Future<void> removeContact(String userId, String contactId);
  // Future<void> updateContactStatus(String userId, String contactId, String status);
}

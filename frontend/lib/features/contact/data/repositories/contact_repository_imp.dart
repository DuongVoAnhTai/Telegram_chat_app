import 'package:frontend/features/contact/domain/entities/contact_entity.dart';
import '../datasource/contact_remote_data_source.dart';

class ContactRepositoryImp {
  final ContactRemoteDataSource datasource;

  ContactRepositoryImp(this.datasource);

  @override
  Future<List<ContactEntity>> fetchContacts() async {
    try {
      final contacts = await datasource.fetchContacts();
      return contacts;
    } catch (e) {
      throw Exception('Error fetching contacts: $e');
    }
  }

  @override
  Future<void> addContact(String contactId) async {
    try {
      await datasource.addContact(contactId);
    } catch (e) {
      throw Exception('Error adding contact: $e');
    }
  }
}

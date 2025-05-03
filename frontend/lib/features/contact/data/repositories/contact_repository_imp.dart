import 'package:frontend/features/contact/domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasource/contact_remote_data_source.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource datasource;

  ContactRepositoryImpl({required this.datasource});

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
  Future<void> addContact(String email) async {
    try {
      await datasource.addContact(email);
    } catch (e) {
      throw Exception('Error adding contact: $e');
    }
  }
}

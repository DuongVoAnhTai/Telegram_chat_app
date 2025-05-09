import '../repositories/contact_repository.dart';

class DeleteContactUseCase {
  final ContactRepository repository;

  DeleteContactUseCase(this.repository);

  Future<void> call(String contactId) async {
    return await repository.deleteContact(contactId);
  }
}

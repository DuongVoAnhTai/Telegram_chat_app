import '../repositories/contact_repository.dart';

class AddContactUseCase {
  final ContactRepository _contactRepository;

  AddContactUseCase(this._contactRepository);

  Future<void> call({required String email}) async {
    await _contactRepository.addContact(email: email);
  }
}

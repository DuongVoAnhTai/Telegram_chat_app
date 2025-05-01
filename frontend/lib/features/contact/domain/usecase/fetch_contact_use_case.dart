import 'package:frontend/features/contact/domain/entities/contact_entity.dart';
import '../repositories/contact_repository.dart';

class FetchContactUseCase {
  final ContactRepository _contactRepository;

  FetchContactUseCase(this._contactRepository);

  Future<List<ContactEntity>> call() async {
    return await _contactRepository.fetchContacts();
  }
}

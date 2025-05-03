import '../repositories/conversation_repository.dart';

class CheckCreateUseCase {
  final ConversationRepository repository;
  CheckCreateUseCase(this.repository);

  Future<String> call(String contactId) async {
    return await repository.checkCreateConversation(contactId);
  }
}

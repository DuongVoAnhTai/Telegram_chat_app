import '../repositories/conversation_repository.dart';

class ChangeConverNameUseCase {
  final ConversationRepository repository;
  ChangeConverNameUseCase(this.repository);

  Future<void> call(String conversationId, String newName) async {
    return repository.changeConversationName(conversationId, newName);
  }
}

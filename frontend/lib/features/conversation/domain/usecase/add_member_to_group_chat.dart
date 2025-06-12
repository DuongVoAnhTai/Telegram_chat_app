import '../repositories/conversation_repository.dart';

class AddMemberToGroupChatUseCase {
  final ConversationRepository repository;
  AddMemberToGroupChatUseCase(this.repository);

  Future<void> call(String conversationId, List<String> userIds) async {
    return repository.addMemberToGroupChat(conversationId, userIds);
  }
}

import '../repositories/conversation_repository.dart';

class AddMemberToGroupChatUseCase {
  final ConversationRepository repository;
  AddMemberToGroupChatUseCase(this.repository);

  Future<void> call(String conversationId, String newMemberId) async {
    return repository.addMemberToGroupChat(conversationId, newMemberId);
  }
}

import '../repositories/conversation_repository.dart';

class RemoveMemberUseCase {
  final ConversationRepository repository;
  RemoveMemberUseCase(this.repository);

  Future<void> call(String conversationId, String newMemberId) async {
    return repository.removeMemberFromGroupChat(conversationId, newMemberId);
  }
}

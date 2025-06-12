import '../repositories/conversation_repository.dart';

class GetParticipantsUseCase {
  final ConversationRepository repository;
  GetParticipantsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(String conversationId) async {
    return repository.getParticipants(conversationId);
  }
}

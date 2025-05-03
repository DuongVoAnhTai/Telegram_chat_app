import 'package:frontend/features/conversation/domain/repositories/conversation_repository.dart';

class CreateConversationUseCase {
  final ConversationRepository repository;

  CreateConversationUseCase(this.repository);

    Future<void> call(String participantId) async {
    return await repository.createConversations(participantId);
  }
}
import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

import '../repositories/conversation_repository.dart';

class FetchConversationUseCase {
  final ConversationRepository repository;

  FetchConversationUseCase(this.repository);

  Future<List<ConversationEntity>> call() async {
    return await repository.fetchConversations();
  }
}

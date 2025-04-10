import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationRepository {
  Future<List<ConversationEntity>> fetchConversations();
}

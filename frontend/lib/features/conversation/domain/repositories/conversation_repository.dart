import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationRepository {
  Future<List<ConversationEntity>> fetchConversations();
  Future<void> createConversations(String participantId);
  Future<String> checkCreateConversation(String contactId);
  Future<void> createGroupChat(List<String> participantIds, String groupName);
}

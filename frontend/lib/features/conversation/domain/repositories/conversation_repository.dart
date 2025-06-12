import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationRepository {
  Future<List<ConversationEntity>> fetchConversations();
  Future<void> createConversations(String participantId);
  Future<String> checkCreateConversation(String contactId);
  Future<void> createGroupChat(List<String> participantIds, String groupName);
  Future<void> addMemberToGroupChat(String conversationId, List<String> userIds);
  Future<List<Participant>> getParticipants(String conversationId);  
  Future<void> removeMemberFromGroupChat(String conversationId, String memberId);
  Future<void> changeConversationName(String conversationId, String newName);
}

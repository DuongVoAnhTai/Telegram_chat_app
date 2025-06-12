abstract class ConversationEvent {}

class FetchConversations extends ConversationEvent {}

class CreateConversation extends ConversationEvent {
  final String participantId;
  CreateConversation(this.participantId);
}

class DeleteConversation extends ConversationEvent {
  final String conversationId;
  DeleteConversation(this.conversationId);
}
class CreateGroupChat extends ConversationEvent {
  final List<String> participantIds;
  final String groupName;

  CreateGroupChat(this.participantIds, this.groupName);
}

abstract class ConversationEvent {}

class FetchConversations extends ConversationEvent {}

class CreateConversation extends ConversationEvent {
  final String participantId;
  CreateConversation(this.participantId);
}

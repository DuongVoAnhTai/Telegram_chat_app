abstract class ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {
  final String message;
  final String conversationId;
  SendMessageEvent(this.message, this.conversationId);
}

class ResetChatbotEvent extends ChatbotEvent {} // Sự kiện mới để reset chatbot
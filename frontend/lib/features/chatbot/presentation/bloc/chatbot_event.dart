abstract class ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {
  final String message;
  SendMessageEvent(this.message);
}

class ResetChatbotEvent extends ChatbotEvent {} // Sự kiện mới để reset chatbot
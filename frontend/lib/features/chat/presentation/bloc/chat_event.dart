abstract class ChatEvent {}

class LoadMessageEvent extends ChatEvent {
  final String conversationId;
  LoadMessageEvent(this.conversationId);
}

class SendMessagesEvent extends ChatEvent {
  final String conversationId;
  final String text;
  SendMessagesEvent(this.conversationId, this.text);
}

class ReceiveMessagesEvent extends ChatEvent {
  final Map<String, dynamic> message;
  ReceiveMessagesEvent(this.message);
}

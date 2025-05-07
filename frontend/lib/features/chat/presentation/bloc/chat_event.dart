abstract class ChatEvent {}

class LoadMessageEvent extends ChatEvent {
  final String conversationId;
  LoadMessageEvent(this.conversationId);
}

class SendMessagesEvent extends ChatEvent {
  final String conversationId;
  final String text;
  final List<String>? imageUrls;
  SendMessagesEvent(this.conversationId, this.text, {this.imageUrls});
}

class ReceiveMessagesEvent extends ChatEvent {
  final Map<String, dynamic> message;
  ReceiveMessagesEvent(this.message);
}

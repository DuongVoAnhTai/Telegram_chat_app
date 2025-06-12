class ChatbotEntity {
  final String id;
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatbotEntity({
    required this.id,
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}
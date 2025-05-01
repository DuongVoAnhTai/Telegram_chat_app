class MessageEntity{
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String image;
  final DateTime createAt;

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createAt,
    required this.image,
  });
}

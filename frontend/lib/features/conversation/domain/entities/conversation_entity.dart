class ConversationEntity {
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String conversationName;
  final String savedMessagesId;
  final String? profilePic;
  ConversationEntity({
    required this.id,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.conversationName,
    required this.savedMessagesId,
    this.profilePic,
  });
}

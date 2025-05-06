class ConversationEntity{
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String conversationName;
  ConversationEntity({required this.id,required this.participantName, required this.lastMessage,required this.lastMessageTime, required this.conversationName});
}
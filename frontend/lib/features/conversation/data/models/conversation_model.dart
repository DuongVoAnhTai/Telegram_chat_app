import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required id,
    required participantName,
    required lastMessage,
    required lastMessageTime,
  }) : super(
         id: id,
         participantName: participantName,
         lastMessage: lastMessage,
         lastMessageTime: lastMessageTime,
       );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participantName: json['participantName'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
    );
  }
}

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
    print("type of value: ${json['participants'].runtimeType}");
    return ConversationModel(
      id: json['_id'],
      participantName: json['participants'].toString(),
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['updatedAt']),
    );
  }
}

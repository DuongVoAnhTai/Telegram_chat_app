import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

import '../../../../core/services/token.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required id,
    required participantName,
    required lastMessage,
    required lastMessageTime,
    required conversationName,
  }) : super(
         id: id,
         participantName: participantName,
         lastMessage: lastMessage,
         lastMessageTime: lastMessageTime,
        conversationName: conversationName,
       );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final _storage = TokenStorageService();
    final userId = _storage.getUserId();
    final participants = json['participants'] as List<dynamic>;
    final names = participants.where((p) => p['_id'] != userId).map((p) => p['fullName'].toString()).join(", ");
    return ConversationModel(
      id: json['_id'],
      participantName: names,
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['updatedAt']),
      conversationName: json['name'] =="" ? names : json['name'],
    );
  }
}

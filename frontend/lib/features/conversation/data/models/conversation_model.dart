import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/token.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required id,
    required participantName,
    required lastMessage,
    required lastMessageTime,
    required conversationName,
    required savedMessagesId,
    String? profilePic,
  }) : super(
         id: id,
         participantName: participantName,
         lastMessage: lastMessage,
         lastMessageTime: lastMessageTime,
         conversationName: conversationName,
         savedMessagesId: savedMessagesId,
         profilePic: profilePic,
       );

  static Future<ConversationModel> fromJson(Map<String, dynamic> json, String names,) async {
    // Get the other participant's profile picture
    String? profilePic;
    if (json['participants'] != null && json['participants'] is List) {
      final participants = json['participants'] as List;
      if (participants.isNotEmpty) {
        // Get current user ID from storage
        final storage = FlutterSecureStorage();
        final currentUserId = await storage.read(key: 'userId');

        // Find the other participant (not the current user)
        for (var participant in participants) {
          if (participant['_id'] != currentUserId) {
            names = participant['fullName'];
            profilePic = participant['profilePic'];
            break;
          }
        }
      }
    }

    return ConversationModel(
      id: json['_id'],
      participantName: names,
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['updatedAt']),
      conversationName: json['name'] == "" ? names : json['name'],
      savedMessagesId: json['savedMessagesId'] ?? "",
      profilePic: profilePic,
    );
  }
}

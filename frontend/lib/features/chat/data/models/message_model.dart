import 'package:frontend/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    required String text,
    required String image,
    required DateTime createAt,
  }) : super(
         id: id,
         conversationId: conversationId,
         senderId: senderId,
         text: text,
         image: image,
         createAt: createAt,
       );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      text: json['text'],
      image: json['image'] ?? "",
      createAt: DateTime.parse(json['createdAt']),
    );
  }
}

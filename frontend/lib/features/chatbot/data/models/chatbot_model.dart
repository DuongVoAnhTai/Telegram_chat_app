import '../../domain/entities/chatbot_entity.dart';

class ChatbotModel extends ChatbotEntity {
  ChatbotModel({
    required String id,
    required String text,
    required bool isUserMessage,
    required DateTime timestamp,
  }) : super(
    id: id,
    text: text,
    isUserMessage: isUserMessage,
    timestamp: timestamp,
  );

  factory ChatbotModel.fromGeminiResponse(Map<String, dynamic> json) {
    print('Raw Gemini response: $json'); // Debugging
    final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
        'Mình chưa hiểu, bạn có thể nói rõ hơn không? 😊';
    return ChatbotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUserMessage: false,
      timestamp: DateTime.now(),
    );
  }
}
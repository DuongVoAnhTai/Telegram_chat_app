
import '../../domain/entities/chatbot_entity.dart';

abstract class ChatbotState {}

class ChatbotInitialState extends ChatbotState {}

class ChatbotLoadingState extends ChatbotState {
  final List<ChatbotEntity> messages;

  ChatbotLoadingState({required this.messages});
}

class ChatbotLoadedState extends ChatbotState {
  final List<ChatbotEntity> messages;

  ChatbotLoadedState({required this.messages});
}

class ChatbotErrorState extends ChatbotState {
  final String error;
  final List<ChatbotEntity> messages;

  ChatbotErrorState({required this.error, required this.messages});
}
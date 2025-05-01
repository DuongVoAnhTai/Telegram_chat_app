import 'package:frontend/features/chat/domain/entities/message_entity.dart';

abstract class ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<MessageEntity> messages;
  ChatLoadedState(this.messages);
}

class ChatErrorState extends ChatState {
  final String error;
  ChatErrorState(this.error);
}

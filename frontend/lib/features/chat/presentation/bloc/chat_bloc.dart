import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/services/socket.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/fetch_message_use_case.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessageUseCase fetchMessageUseCase;
  final SocketService _socketService = SocketService();
  final List<MessageEntity> _messages = [];
  final _storage = FlutterSecureStorage();

  ChatBloc({required this.fetchMessageUseCase}) : super(ChatLoadingState()) {
    on<LoadMessageEvent>(_onLoadMessage);
    on<SendMessagesEvent>(_onSendMessage);
    on<ReceiveMessagesEvent>(_onReceiveMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);

    // Set up socket listener once
    _socketService.socket.on('newMessage', (data) {
      add(ReceiveMessagesEvent(data));
    });
  }

  Future<void> _onLoadMessage(
      LoadMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(ChatLoadingState());
    try {
      final messages = await fetchMessageUseCase(event.conversationId);
      _messages.clear();
      _messages.addAll(messages);
      emit(ChatLoadedState(List.from(_messages)));

      _socketService.socket.emit('joinConversation', event.conversationId);
    } catch (error) {
      emit(ChatErrorState('Error: $error'));
    }
  }

  Future<void> _onSendMessage(
      SendMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    String userId = await _storage.read(key: 'userId') ?? '';
    print('userId: $userId');

    final senderId = event.senderIdOverride ?? userId; // Use senderIdOverride if provided

    final newMessage = {
      'text': event.text,
      'image': event.imageUrls ?? [],
      'senderId': senderId,
      'conversationId': event.conversationId,
    };

    print("MESSAGE: $newMessage");

    _socketService.socket.emit('sendMessage', newMessage);
  }

  Future<void> _onReceiveMessage(
      ReceiveMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    print("step2: receive event called with data: ${event.message}");
    final messageData = event.message;
    final message = MessageEntity(
      image: (messageData['image'] as List?)?.map((e) => e.toString()).toList() ?? [],
      id: messageData['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: messageData['conversationId'],
      senderId: messageData['senderId'],
      text: messageData['text'],
      createAt: DateTime.parse(messageData['createdAt']),
    );

    // Check for duplicates based on id or text+senderId combination
    if (!_messages.any((m) => m.id == message.id || (m.text == message.text && m.senderId == message.senderId))) {
      _messages.add(message);
      emit(ChatLoadedState(List.from(_messages)));
    } else {
      print("Duplicate message detected, ignoring: ${message.text}");
    }
  }

  Future<void> _onDeleteMessage(
      DeleteMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      _socketService.socket.emit('deleteMessage', {
        'messageId': event.messageId,
        'conversationId': event.conversationId,
      });

      _messages.removeWhere((message) => message.id == event.messageId);
      emit(ChatLoadedState(List.from(_messages)));
    } catch (error) {
      emit(ChatErrorState('Error deleting message: $error'));
    }
  }
}
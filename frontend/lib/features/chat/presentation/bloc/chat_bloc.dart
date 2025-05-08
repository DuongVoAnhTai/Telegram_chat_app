import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/socket.dart';
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
  }

  Future<void> _onLoadMessage(LoadMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
    try {
      final messages = await fetchMessageUseCase(event.conversationId);
      _messages.clear();
      _messages.addAll(messages);
      emit(ChatLoadedState(List.from(_messages)));

      _socketService.socket.off('newMessage');
      _socketService.socket.emit('joinConversation', event.conversationId);
      _socketService.socket.on('newMessage', (data) {
        print('step1: data');
        add(ReceiveMessagesEvent(data));
      });
    } catch (error) {
      emit(ChatErrorState('Error: $error'));
    }
  }

  Future<void> _onSendMessage(SendMessagesEvent event, Emitter<ChatState> emit) async {
    String userId = await _storage.read(key: 'userId') ?? '';
    print('userId: $userId');

    final newMessage = {
      'text': event.text,
      'image': event.imageUrls ?? [],
      'senderId': userId,
      'conversationId': event.conversationId,
    };

    print("MESSAGE: $newMessage");

    _socketService.socket.emit('sendMessage', newMessage);
  }

  Future<void> _onReceiveMessage(ReceiveMessagesEvent event, Emitter<ChatState> emit) async {
    print("step2: receive event called");
    print(event.message);
    final message =  MessageEntity(image: (event.message['image'] as List?)?.map((e) => e.toString()).toList() ?? [], id: event.message['_id'], conversationId: event.message['conversationId'], senderId: event.message['senderId'], text: event.message['text'], createAt: DateTime.parse(event.message['createdAt']));
    _messages.add(message);
    emit(ChatLoadedState(List.from(_messages)));
  }
}

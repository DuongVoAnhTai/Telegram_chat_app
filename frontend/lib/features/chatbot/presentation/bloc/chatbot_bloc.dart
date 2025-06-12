import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/socket.dart';
import '../../domain/entities/chatbot_entity.dart';
import '../../domain/usecases/send_message_use_case.dart';
import 'chatbot_event.dart';
import 'chatbot_state.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final SendMessageUseCase sendMessageUseCase;
  final SocketService _socketService = SocketService();
  UserEntity user;
  List<ChatbotEntity> messages = [];

  ChatbotBloc({
    required this.sendMessageUseCase,
    required this.user,
  }) : super(ChatbotInitialState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ResetChatbotEvent>(_onResetChatbot); // Thêm xử lý sự kiện reset
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatbotState> emit) async {
    final userMessage = ChatbotEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.message,
      isUserMessage: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);
    emit(ChatbotLoadingState(messages: List.from(messages)));

    try {
      final botMessage = await sendMessageUseCase(event.message, user: user);
      messages.add(botMessage);
      emit(ChatbotLoadedState(messages: List.from(messages)));
    } catch (error) {
      emit(ChatbotErrorState(error: 'Oops, có lỗi xảy ra! Hãy thử lại nhé!', messages: List.from(messages)));
    }
  }

  Future<void> _onResetChatbot(ResetChatbotEvent event, Emitter<ChatbotState> emit) async {
    messages.clear(); // Xóa danh sách tin nhắn
    emit(ChatbotInitialState()); // Phát ra trạng thái ban đầu
  }

  void updateUser(UserEntity newUser) {
    user = newUser;
  }
}
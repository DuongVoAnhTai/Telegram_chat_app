import 'package:frontend/core/services/socket.dart';
import 'package:frontend/features/conversation/domain/usecase/fetch_conversation_use_case.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/conversation_model.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final FetchConversationUseCase fetchConversationUseCase;
  final SocketService _socketService = SocketService();

  ConversationBloc({required this.fetchConversationUseCase})
    : super(ConversationInitial()) {
    on<FetchConversations>(_onFetchConversations);
    _initSocketListeners();
  }

  void _initSocketListeners() {
    try {
      _socketService.socket.on('updateConversations', (data) {
        print("syncing");
        add(FetchConversations());
      });
      print("Socket listener for updateConversations initialized.");
    } catch (error) {
      print("Error initializing socket listener: $error");
    }
  }

  Future<void> _onFetchConversations(
    FetchConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final conversations = await fetchConversationUseCase();
      emit(ConversationLoaded(conversations));
    } catch (error) {
      emit(ConversationError(error.toString()));
    }
  }
}

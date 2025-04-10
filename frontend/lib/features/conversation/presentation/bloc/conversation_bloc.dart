import 'package:frontend/features/conversation/domain/usecase/fetch_conversation_use_case.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final FetchConversationUseCase fetchConversationUseCase;

  ConversationBloc({required this.fetchConversationUseCase})
    : super(ConversationInitial()) {
    on<FetchConversations>(_onFetchConversations);
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

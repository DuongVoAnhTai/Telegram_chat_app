import 'package:frontend/core/services/socket.dart';
import 'package:frontend/features/conversation/domain/usecase/add_member_to_group_chat.dart';
import 'package:frontend/features/conversation/domain/usecase/check_create_use_case.dart';
import 'package:frontend/features/conversation/domain/usecase/create_conversation_use_case.dart';
import 'package:frontend/features/conversation/domain/usecase/create_group_chat.dart';
import 'package:frontend/features/conversation/domain/usecase/fetch_conversation_use_case.dart';
import 'package:frontend/features/conversation/domain/usecase/get_participants.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../data/models/conversation_model.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final FetchConversationUseCase fetchConversationUseCase;
  final CreateConversationUseCase createConversationUseCase;
  final CreateGroupChatUseCase createGroupChatUseCase;
  final AddMemberToGroupChatUseCase addMemberToGroupChatUseCase;
  final GetParticipantsUseCase getParticipantsUseCase;
  final SocketService _socketService = SocketService();

  ConversationBloc({
    required this.fetchConversationUseCase,
    required this.createConversationUseCase,
    required this.createGroupChatUseCase,
    required this.addMemberToGroupChatUseCase,
    required this.getParticipantsUseCase,
  }) : super(ConversationInitial()) {
    on<FetchConversations>(_onFetchConversations);
    on<CreateConversation>(_onCreateConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<CreateGroupChat>(_onCreateGroupChat);
    on<AddMemberToGroupChat>(_onAddMemberToGroupChat);
    on<GetParticipants>(_onGetParticipants);
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

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationCreating());
    try {
      await createConversationUseCase(event.participantId);
    } catch (error) {
      emit(ConversationError(error.toString()));
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      _socketService.socket.emit('deleteConversation', event.conversationId);
      add(FetchConversations());
    } catch (error) {
      emit(ConversationError(error.toString()));
    }
  }
  Future<void> _onCreateGroupChat(
    CreateGroupChat event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationCreating());
    try {
      await createGroupChatUseCase.createGroupChat(event.participantIds, event.groupName);
      _socketService.socket.emit('createGroupChat', {
        'participantIds': event.participantIds,
        'groupName': event.groupName,
      });
      add(FetchConversations());
    } catch (error) {
      emit(ConversationError(error.toString()));
    }
  }
  Future<void> _onAddMemberToGroupChat(
    AddMemberToGroupChat event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await addMemberToGroupChatUseCase(event.conversationId, event.newMemberId);
      _socketService.socket.emit('addMemberToGroupChat', {
        'conversationId': event.conversationId,
        'newMemberId': event.newMemberId,
      });
      emit(MembersAdded(event.conversationId, event.newMemberId));
      add(FetchConversations());
    } catch (error) {
      emit(ConversationError(error.toString()));
    }
  }
  Future<void> _onGetParticipants(
    GetParticipants event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final participants = await getParticipantsUseCase(event.conversationId);
      emit(ParticipantsLoaded(participants));
    } catch (error) {
      print("herererererer $error");
      emit(ConversationError(error.toString()));
    }
  }
}

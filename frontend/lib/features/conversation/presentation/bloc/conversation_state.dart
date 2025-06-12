import 'package:frontend/features/conversation/data/models/conversation_model.dart';

import '../../domain/entities/conversation_entity.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ConversationEntity> conversations;

  ConversationLoaded(this.conversations);
}

class ConversationCreating extends ConversationState {}

class ConversationError extends ConversationState {
  final String message;

  ConversationError(this.message);
}

class MembersAdded extends ConversationState {
  final String conversationId;
  final String newMember;

  MembersAdded(this.conversationId, this.newMember);
}

class ParticipantsLoaded extends ConversationState {
  final List<Participant> participants;

  ParticipantsLoaded(this.participants);
}

class MembersRemoved extends ConversationState {
  final String conversationId;
  final String memberId;

  MembersRemoved(this.conversationId, this.memberId);
}

class ChangedConverName extends ConversationState {
  final String conversationId;
  final String newName;

  ChangedConverName(this.conversationId, this.newName);
}

class UpdatedGroupProfilePic extends ConversationState {
  final String conversationId;
  final String profilePic;

  UpdatedGroupProfilePic(this.conversationId, this.profilePic);
}

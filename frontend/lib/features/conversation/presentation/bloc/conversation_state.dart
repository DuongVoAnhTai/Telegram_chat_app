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
  final  List<Map<String, dynamic>> participants;

  ParticipantsLoaded(this.participants);
}
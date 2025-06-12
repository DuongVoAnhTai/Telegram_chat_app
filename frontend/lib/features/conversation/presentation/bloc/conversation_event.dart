abstract class ConversationEvent {}

class FetchConversations extends ConversationEvent {}

class CreateConversation extends ConversationEvent {
  final String participantId;
  CreateConversation(this.participantId);
}

class DeleteConversation extends ConversationEvent {
  final String conversationId;
  DeleteConversation(this.conversationId);
}

class CreateGroupChat extends ConversationEvent {
  final List<String> participantIds;
  final String groupName;

  CreateGroupChat(this.participantIds, this.groupName);
}

class AddMemberToGroupChat extends ConversationEvent {
  final String conversationId;
  final String newMemberId;
  AddMemberToGroupChat(this.conversationId, this.newMemberId);
}

class RemoveMembers extends ConversationEvent {
  final String conversationId;
  final String memberId;
  RemoveMembers(this.conversationId, this.memberId);
}

class GetParticipants extends ConversationEvent {
  final String conversationId;
  GetParticipants(this.conversationId);
}

class ChangeConverName extends ConversationEvent {
  final String conversationId;
  final String newName;
  ChangeConverName(this.conversationId, this.newName);
}

class UpdateGroupProfilePic extends ConversationEvent {
  final String conversationId;
  final String profilePic;
  UpdateGroupProfilePic(this.conversationId, this.profilePic);
}

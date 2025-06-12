import 'package:frontend/features/conversation/domain/repositories/conversation_repository.dart';

class CreateGroupChatUseCase {
  final ConversationRepository repository;

  CreateGroupChatUseCase(this.repository);

    Future<void> createGroupChat(List<String> participantIds, String groupName) async {
    return await repository.createGroupChat(participantIds, groupName);
  }
}
import 'package:frontend/features/conversation/domain/repositories/conversation_repository.dart';

class UpdateGroupProfilePicUseCase {
  final ConversationRepository repository;

  UpdateGroupProfilePicUseCase(this.repository);

  Future<void> call(String conversationId, String profilePic) async {
    return await repository.updateGroupProfilePic(conversationId, profilePic);
  }
}

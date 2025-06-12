import 'package:frontend/features/conversation/data/models/conversation_model.dart';

import '../repositories/conversation_repository.dart';

class GetParticipantsUseCase {
  final ConversationRepository repository;
  GetParticipantsUseCase(this.repository);

  Future<List<Participant>> call(String conversationId) async {
    return repository.getParticipants(conversationId);
  }
}

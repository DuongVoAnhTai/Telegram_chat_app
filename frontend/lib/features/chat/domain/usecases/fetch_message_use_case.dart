import 'package:frontend/features/chat/domain/repositories/message_repository.dart';
import '../entities/message_entity.dart';

class FetchMessageUseCase {
  final MessageRepository repository;

  FetchMessageUseCase(this.repository);

  Future<List<MessageEntity>> call(String conversationId) async {
    return await repository.fetchMessages(conversationId);
  }
}

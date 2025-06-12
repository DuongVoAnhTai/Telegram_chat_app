import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_data_source.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remote;

  MessageRepositoryImpl({required this.remote});

  @override
  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    return await remote.fetchMessages(conversationId);
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }
}

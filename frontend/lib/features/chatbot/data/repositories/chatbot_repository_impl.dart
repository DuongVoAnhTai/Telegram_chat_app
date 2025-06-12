import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../domain/entities/chatbot_entity.dart';
import '../datasources/chatbot_remote_data_source.dart';
import '../models/chatbot_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatbotEntity> sendMessage(String message, {required UserEntity user}) async {
    try {
      final ChatbotModel model = await remoteDataSource.sendMessage(message, user: user);
      return model;
    } catch (e) {
      rethrow;
    }
  }
}
import '../entities/chatbot_entity.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

abstract class ChatbotRepository {
  Future<ChatbotEntity> sendMessage(String message, {required UserEntity user});
}
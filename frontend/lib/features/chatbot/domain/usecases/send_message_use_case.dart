import '../repositories/chatbot_repository.dart';
import '../entities/chatbot_entity.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class SendMessageUseCase {
  final ChatbotRepository repository;

  SendMessageUseCase(this.repository);

  Future<ChatbotEntity> call(String message, {required UserEntity user}) async {
    // Có thể thêm thông tin người dùng vào yêu cầu API
    return await repository.sendMessage(message, user: user);
  }
}
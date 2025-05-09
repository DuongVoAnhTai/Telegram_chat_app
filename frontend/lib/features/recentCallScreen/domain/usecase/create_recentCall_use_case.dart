import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';

class CreateRecentcallUseCase {
  final RecentCallRepository repository;
  CreateRecentcallUseCase(this.repository);
  Future<void> call(String conversationId, String callType) async {
    return await repository.createRecentCall(conversationId, callType);
  }
}
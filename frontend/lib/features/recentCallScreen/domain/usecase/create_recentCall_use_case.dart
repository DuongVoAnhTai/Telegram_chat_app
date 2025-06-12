import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';

class CreateRecentCallUseCase {
  final RecentCallRepository repository;
  CreateRecentCallUseCase(this.repository);
  Future<void> call(String conversationId, String callType) async {
    return await repository.createRecentCall(conversationId, callType);
  }
}
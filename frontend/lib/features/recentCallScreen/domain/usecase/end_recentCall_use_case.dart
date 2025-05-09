import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';

class EndRecentcallUseCase {
  final RecentCallRepository repository;
  EndRecentcallUseCase(this.repository);
  Future<void> call(String conversationId) async {
    return await repository.endRecentCall(conversationId);
  }
}
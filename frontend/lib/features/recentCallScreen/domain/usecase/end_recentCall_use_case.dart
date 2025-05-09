import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';

class EndRecentCallUseCase {
  final RecentCallRepository repository;
  EndRecentCallUseCase(this.repository);
  Future<void> call(String conversationId) async {
    return await repository.endRecentCall(conversationId);
  }
}
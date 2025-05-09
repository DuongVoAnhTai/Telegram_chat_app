
import 'package:frontend/features/recentCallScreen/domain/entities/recentCall_entity.dart';
import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';

class FetchRecentcallUseCase {
  final RecentCallRepository repository;
  FetchRecentcallUseCase(this.repository);

  Future<List<RecentCallEntity>> call() async {
    return await repository.fetchRecentCalls();
  }
}
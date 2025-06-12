import 'package:frontend/features/recentCallScreen/domain/entities/recentCall_entity.dart';

abstract class RecentCallRepository {
  Future<List<RecentCallEntity>> fetchRecentCalls();
  Future<void> createRecentCall(String conversationId, String callType);
  Future<void> endRecentCall(String conversationId);
}
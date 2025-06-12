import 'package:frontend/features/recentCallScreen/data/dataSources/recentCall_remote_data_source.dart';
import 'package:frontend/features/recentCallScreen/domain/entities/recentCall_entity.dart';
import 'package:frontend/features/recentCallScreen/domain/repositories/recentCall_repository.dart';

class RecentcallRepositoryImpl implements RecentCallRepository {
  final RecentCallRemoteDataSource dataSource;
  RecentcallRepositoryImpl({required this.dataSource});

  @override
  Future<void> createRecentCall(String conversationId, String callType) async{
    return await dataSource.createRecentCall(conversationId: conversationId, callType: callType);
  }

  @override
  Future<void> endRecentCall(String conversationId) async{
    return await dataSource.endRecentCall(conversationId: conversationId);
  }

  @override
  Future<List<RecentCallEntity>> fetchRecentCalls() async {
    return await dataSource.fetchRecentCalls();
  }

}
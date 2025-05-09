import 'package:frontend/features/recentCallScreen/domain/entities/recentCall_entity.dart';

class RecentCallModel extends RecentCallEntity {
  RecentCallModel(
    {
      required super.userId, 
      required super.conversationId, 
      required super.callType, 
      required super.startAt, 
      required super.endAt
    });
  static Future<RecentCallModel> fromJson(Map<String,dynamic> json) async {
      return RecentCallModel(
        userId: json['userId'],
        conversationId: json['conversationId'],
        callType: json['callType'], 
        startAt: DateTime.parse(json['startedAt']), 
        endAt: DateTime.parse(json['endedAt'])
        );
  }
}
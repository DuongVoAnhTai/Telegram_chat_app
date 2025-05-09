class RecentCallEntity {
  final String userId;
  final String conversationId;
  final String callType;
  final DateTime startAt;
  final DateTime endAt;
  RecentCallEntity({
    required this.userId,
    required this.conversationId,
    required this.callType,
    required this.startAt,
    required this.endAt,
  });
}

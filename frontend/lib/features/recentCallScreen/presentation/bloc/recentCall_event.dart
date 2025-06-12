abstract class RecentCallEvent {}

class FetchRecentCalls extends RecentCallEvent {}
class CreateRecentCall extends RecentCallEvent {
  final String conversationId;
  final String userId;
  CreateRecentCall(this.conversationId, this.userId);
}
class EndRecentCall extends RecentCallEvent {
  final String conversationId;
  EndRecentCall(this.conversationId);
}
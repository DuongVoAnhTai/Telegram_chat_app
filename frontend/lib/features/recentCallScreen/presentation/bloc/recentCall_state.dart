
import 'package:frontend/features/recentCallScreen/domain/entities/recentCall_entity.dart';

abstract class RecentCallState {}

class RecentCallInitial extends RecentCallState {}
class RecentCallLoading extends RecentCallState {}

class RecentCallLoaded extends  RecentCallState {
  final List<RecentCallEntity> recentCalls;

  RecentCallLoaded(this.recentCalls);
}

class RecentCallError extends RecentCallState {
  final String message;

  RecentCallError(this.message);
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/socket.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/fetch_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_event.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_state.dart';

class RecentCallBloc extends Bloc<RecentCallEvent, RecentCallState>{
  final FetchRecentcallUseCase fetchRecentcallUseCase;
  final SocketService _socketService = SocketService();

  RecentCallBloc(recentCallRepository, {
    required this.fetchRecentcallUseCase,
  }) : super(RecentCallInitial()){
    on<FetchRecentCalls>(_onFetchRecentCalls);
    _initSocketListeners();
  }

  void _initSocketListeners() {
    try {
      _socketService.socket.on('updateRecentCalls', (data) {
        print("syncing");
        add(FetchRecentCalls());
      });
      print("Socket listener for updateRecentCalls initialized.");
    } catch (error) {
      print("Error initializing socket listener: $error");
    }
  }

  Future<void> _onFetchRecentCalls(
    FetchRecentCalls event,
    Emitter<RecentCallState> emit,
  ) async {
    emit(RecentCallLoading());
    try{
      final recentCalls = await fetchRecentcallUseCase();
      emit(RecentCallLoaded(recentCalls));
    }catch(error){
      emit(RecentCallError(error.toString()));
    }
  }
}
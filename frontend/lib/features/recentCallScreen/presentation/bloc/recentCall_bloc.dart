import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/socket.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/create_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/end_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/fetch_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_event.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_state.dart';

class RecentCallBloc extends Bloc<RecentCallEvent, RecentCallState>{
  final FetchRecentcallUseCase fetchRecentcallUseCase;
  final CreateRecentCallUseCase createRecentCallUseCase;
  final EndRecentCallUseCase endRecentCallUseCase;
  final SocketService _socketService = SocketService();

  RecentCallBloc({
    required this.fetchRecentcallUseCase,
    required this.createRecentCallUseCase,
    required this.endRecentCallUseCase
  }) : super(RecentCallInitial()){
    on<FetchRecentCalls>(_onFetchRecentCalls);
    on<CreateRecentCall>(_onCreateRecentCall);
    on<EndRecentCall>(_onEndRecentCall);
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
  Future<void> _onCreateRecentCall(
    CreateRecentCall event,
    Emitter<RecentCallState> emit,
  ) async {
    emit(RecentCallLoading());
    try{
      await createRecentCallUseCase(event.conversationId, event.userId);
    }catch(error)
    {
      emit(RecentCallError(error.toString()));
    }
  }
  Future<void> _onEndRecentCall(
    EndRecentCall event,
    Emitter<RecentCallState> emit,
  ) async {
    emit(RecentCallLoading());
    try{
      await endRecentCallUseCase(event.conversationId);
    }catch(error)
    {
      emit(RecentCallError(error.toString()));
    }
  }
}
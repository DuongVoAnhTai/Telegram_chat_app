import 'package:frontend/features/auth/domain/usecases/login_use_case.dart';
import 'package:frontend/features/auth/domain/usecases/profile_use_case.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_use_case.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_use_case.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final _storage = FlutterSecureStorage();

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(
        event.username,
        event.email,
        event.password,
      );
      await _storage.write(key: 'token', value: user.token);
      await _storage.write(key: 'userId', value: user.id);
      emit(AuthSuccess(message: "Registration successful"));
      // Tự động fetch profile sau khi đăng ký
      emit(AuthLoading());
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(user: profile));
    } catch (error) {
      emit(AuthFailure(error: 'Registration failed: $error'));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      await _storage.write(key: 'token', value: user.token);
      await _storage.write(key: 'userId', value: user.id);
      emit(AuthSuccess(message: "Login successful"));
      // Tự động fetch profile sau khi đăng nhập
      emit(AuthLoading());
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(user: profile));
    } catch (error) {
      emit(AuthFailure(error: 'Login failed: $error'));
    }
  }

  Future<void> _onGetUserProfile(GetUserProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await getUserProfileUseCase();
      emit(ProfileLoaded(user: user));
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await updateProfileUseCase(
        fullName: event.fullname,
        bio: event.bio,
        dob: event.dob,
        profilePic: event.profilePic,
      );
      emit(ProfileUpdated(
        user: user,
        message: "Profile updated successfully",
      ));
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/design_system/theme/theme.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/usecases/login_use_case.dart';
import 'package:frontend/features/auth/domain/usecases/register_use_case.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/register_page.dart';
import 'package:frontend/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:frontend/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:frontend/features/conversation/domain/usecase/fetch_conversation_use_case.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/conversation/presentation/pages/message_page.dart';
import 'package:frontend/widgets/screen/chat/chat_page.dart';

Future<void> main() async {
  // Xác định đường dẫn thư mục gốc của project
  String projectRoot = Directory.current.path;

  // Load file .env từ thư mục gốc
  await dotenv.load(fileName: ".env");
  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSource(),
  );
  final conversationRepository = ConversationRepositoryImpl(
    converstionRemoteDataSource: ConversationRemoteDataSource(),
  );

  runApp(
    ChatApp(
      authRepository: authRepository,
      conversationRepository: conversationRepository,
    ),
  );
}

class ChatApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ConversationRepositoryImpl conversationRepository;

  const ChatApp({
    super.key,
    required this.authRepository,
    required this.conversationRepository,
  });
  @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(home: ChatScreen());
  // }
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => AuthBloc(
                registerUseCase: RegisterUseCase(repository: authRepository),
                loginUseCase: LoginUseCase(repository: authRepository),
              ),
        ),
        BlocProvider(
          create:
              (_) => ConversationBloc(
                fetchConversationUseCase: FetchConversationUseCase(
                  conversationRepository,
                ),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: MessagePage(),
        routes: {
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
          '/chatPage': (_) => ChatPage(),
          '/conversationsPage': (_) => MessagePage(),
        },
      ),
    );
  }
}

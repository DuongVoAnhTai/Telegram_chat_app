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
// import 'package:frontend/features/auth/presentation/pages/login_page.dart';
// import 'package:frontend/features/auth/presentation/pages/register_page.dart';
import 'package:frontend/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:frontend/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:frontend/features/conversation/domain/usecase/fetch_conversation_use_case.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
// import 'package:frontend/features/conversation/presentation/pages/message_page.dart';
// import 'package:frontend/widgets/screen/chat/chat_page.dart';
import 'core/navigation/routers.dart';
import 'core/services/socket.dart';
import 'features/chat/data/datasources/message_remote_data_source.dart';
import 'features/chat/data/repositories/message_repository.dart';
import 'features/chat/domain/usecases/fetch_message_use_case.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final socketService = SocketService();
  await socketService.initSocket();

  // Load file .env từ thư mục gốc
  await dotenv.load(fileName: ".env");

  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSource(),
  );
  final conversationRepository = ConversationRepositoryImpl(
    converstionRemoteDataSource: ConversationRemoteDataSource(),
  );
  final messageRepository = MessageRepositoryImpl(
    remote: MessageRemoteDataSource(),
  );

  runApp(
    ChatApp(
      authRepository: authRepository,
      conversationRepository: conversationRepository,
      messageRepository: messageRepository,
    ),
  );
}

class ChatApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ConversationRepositoryImpl conversationRepository;
  final MessageRepositoryImpl messageRepository;

  const ChatApp({
    super.key,
    required this.authRepository,
    required this.conversationRepository,
    required this.messageRepository,
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
        BlocProvider(
          create:
              (_) => ChatBloc(
                fetchMessageUseCase: FetchMessageUseCase(messageRepository),
              ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        // home: MessagePage(),
        // routes: {
        //   '/login': (_) => LoginPage(),
        //   '/register': (_) => RegisterPage(),
        //   '/chatPage': (_) => ChatPage(),
        //   '/conversationsPage': (_) => MessagePage(),
        // },
        routerConfig: router,
      ),
    );
  }
}

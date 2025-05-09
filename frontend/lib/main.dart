import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/design_system/theme/theme.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/usecases/login_use_case.dart';
import 'package:frontend/features/auth/domain/usecases/profile_use_case.dart';
import 'package:frontend/features/auth/domain/usecases/register_use_case.dart';
import 'package:frontend/features/auth/domain/usecases/update_profile_use_case.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/contact/data/datasource/contact_remote_data_source.dart';
import 'package:frontend/features/contact/data/repositories/contact_repository_imp.dart';
import 'package:frontend/features/contact/domain/usecase/add_contact_use_case.dart';
import 'package:frontend/features/contact/domain/usecase/fetch_contact_use_case.dart';
import 'package:frontend/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:frontend/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:frontend/features/conversation/domain/usecase/check_create_use_case.dart';
import 'package:frontend/features/conversation/domain/usecase/create_conversation_use_case.dart';
import 'package:frontend/features/conversation/domain/usecase/fetch_conversation_use_case.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/recentCallScreen/data/dataSources/recentCall_remote_data_source.dart';
import 'package:frontend/features/recentCallScreen/data/repositories/recentCall_repository_impl.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/create_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/end_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/domain/usecase/fetch_recentCall_use_case.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_bloc.dart';
import 'package:provider/provider.dart';
import 'package:stream_video/stream_video.dart';
import 'core/navigation/routers.dart';
import 'core/services/socket.dart';
import 'features/chat/data/datasources/message_remote_data_source.dart';
import 'features/chat/data/repositories/message_repository.dart';
import 'features/chat/domain/usecases/fetch_message_use_case.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/contact/domain/usecase/delete_contact_use_case.dart';
import 'features/contact/presentation/bloc/contact_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage();
  final userId = await storage.read(key: 'userId');
  final streamToken = await storage.read(key: 'streamToken');

  // Only initialize if user info is available
  if (userId != null && streamToken != null) {
    StreamVideo(
      'k5dmbjjwggje',
      user: User.regular(userId: userId, role: 'user', name: 'User $userId'),
      userToken: streamToken,
    );
  }
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
  final contactRepository = ContactRepositoryImpl(
    datasource: ContactRemoteDataSource(),
  );
  final recentCallRepository = RecentcallRepositoryImpl(
    dataSource: RecentCallRemoteDataSource(),
  );
  runApp(
    ChatApp(
      authRepository: authRepository,
      conversationRepository: conversationRepository,
      messageRepository: messageRepository,
      contactRepository: contactRepository, 
      recentcallRepository: recentCallRepository,
    ),
  );
}

class ChatApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ConversationRepositoryImpl conversationRepository;
  final MessageRepositoryImpl messageRepository;
  final ContactRepositoryImpl contactRepository;
  final RecentcallRepositoryImpl recentcallRepository;
  const ChatApp({
    super.key,
    required this.authRepository,
    required this.conversationRepository,
    required this.messageRepository,
    required this.contactRepository,
    required this.recentcallRepository
  });
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Cung cấp RecentcallRepositoryImpl
        Provider<RecentcallRepositoryImpl>.value(
          value: recentcallRepository,
        ),
        BlocProvider(
          create:
              (_) => AuthBloc(
                registerUseCase: RegisterUseCase(repository: authRepository),
                loginUseCase: LoginUseCase(repository: authRepository),
                getUserProfileUseCase: GetUserProfileUseCase(
                  repository: authRepository,
                ),
                updateProfileUseCase: UpdateProfileUseCase(
                  repository: authRepository,
                ),
              ),
        ),
        BlocProvider(
          create:
              (_) => ConversationBloc(
                fetchConversationUseCase: FetchConversationUseCase(
                  conversationRepository,
                ),
                createConversationUseCase: CreateConversationUseCase(
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
        BlocProvider(
          create:
              (_) => ContactBloc(
                fetchContactUserCase: FetchContactUseCase(contactRepository),
                addContactUseCase: AddContactUseCase(contactRepository),
                checkCreateUseCase: CheckCreateUseCase(conversationRepository),
                deleteContactUseCase: DeleteContactUseCase(contactRepository),
              ),
        ),
        BlocProvider(
          create: (_) => RecentCallBloc(
            fetchRecentcallUseCase: FetchRecentcallUseCase(recentcallRepository),
             createRecentCallUseCase: CreateRecentCallUseCase(recentcallRepository),
             endRecentCallUseCase: EndRecentCallUseCase(recentcallRepository)
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

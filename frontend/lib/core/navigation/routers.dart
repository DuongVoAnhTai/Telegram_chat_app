import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/pages/getcode_screen.dart';
import 'package:frontend/features/auth/presentation/pages/login_screen.dart';
import 'package:frontend/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend/features/contact/presentation/pages/contact_page.dart';
import 'package:frontend/features/group/presentation/pages/add_member_page.dart';
import 'package:frontend/features/group/presentation/pages/create_group_page.dart';
import 'package:frontend/features/recentCallScreen/presentation/pages/recentCall_screen.dart';
import 'package:frontend/src/ui/feature/home/home_screen.dart';
import 'package:frontend/src/ui/feature/profile/edit_profile_screen.dart';
import 'package:frontend/src/ui/feature/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chatbot/presentation/bloc/chatbot_bloc.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash', // Bắt đầu từ SplashScreen
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(
      path: '/get-code',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final type =
            state.uri.queryParameters['type'] ??
            'login'; // Mặc định là login nếu không có type
        return GetCodeScreen(email: email, type: type);
      },
    ),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => EditProfileScreen(),
    ),
    GoRoute(
      path: '/chat-page',
      builder: (context, state) {
        final conversationId = state.uri.queryParameters['id'] ?? 'defaultId';
        final mate = state.uri.queryParameters['mate'] ?? 'mate';
        final profilePic = state.uri.queryParameters['profilePic'];
        return ChatPage(conversationId: conversationId, mate: mate, profilePic: profilePic,);
      },
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) {
        final authBloc = context.read<AuthBloc>();
        final chatbotBloc = context.read<ChatbotBloc>();

        // Kiểm tra trạng thái và fetch profile nếu cần
        if (authBloc.state is! ProfileLoaded) {
          authBloc.add(GetUserProfileEvent()); // Fetch profile khi vào route
        } else {
          final user = (authBloc.state as ProfileLoaded).user;
          chatbotBloc.updateUser(user); // Cập nhật ngay nếu đã có profile
        }

        return ChatbotPage();
      },
    ),
    GoRoute(path: '/contact-page', builder: (context, state) => ContactPage()),
    GoRoute(path: '/recent-call', builder: (context, state) {
      return RecentCallScreen();
    }),
    GoRoute(path: '/create-group-page', builder: (context, state) {
      return CreateGroupPage();
    }),
    GoRoute(path: '/add-member-page', builder: (context, state) {
      final converId = state.uri.queryParameters['conversationId'] ?? 'defaultGroupId';
      return AddMemberPage(
        conversationId: converId,
        existingMemberIds: [],
      );
    }),
  ],
);

import 'package:flutter/material.dart';
import 'package:frontend/src/ui/feature/Login/getcode_screen.dart';
import 'package:frontend/src/ui/feature/Login/login_screen.dart';
import 'package:frontend/src/ui/feature/Login/register_screen.dart';
import 'package:frontend/src/ui/feature/home/home_screen.dart';
import 'package:frontend/src/ui/feature/profile/edit_profile_screen.dart';
import 'package:frontend/src/ui/feature/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash', // Bắt đầu từ SplashScreen
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/get-code',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final type = state.uri.queryParameters['type'] ?? 'login'; // Mặc định là login nếu không có type
        return GetCodeScreen(email: email, type: type);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => EditProfileScreen(),
    ),
  ],
);
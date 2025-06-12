import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/chatbot/presentation/bloc/chatbot_bloc.dart';
import 'package:frontend/features/chatbot/presentation/bloc/chatbot_event.dart';
import 'package:frontend/features/conversation/presentation/pages/list_chat_screen.dart';
import 'package:frontend/src/ui/feature/profile/profile_screen.dart';
import 'package:frontend/src/ui/feature/setting/setting_screen.dart';
import 'package:frontend/features/chatbot/presentation/pages/chatbot_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default is profile tab (index 0)

  final List<Widget> _screens = [
    ProfileScreen(),
    ListChatScreen(),
    ChatbotPage(),
    //SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // When the Chatbot tab is selected (index 2)
      context.read<ChatbotBloc>().add(ResetChatbotEvent());
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'ChatBot'),
          //BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/src/ui/feature/chat/list_chat_screen.dart';
import 'package:frontend/src/ui/feature/profile/profile_screen.dart';
import 'package:frontend/src/ui/feature/setting/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Mặc định là tab Chat (index 1)

  final List<Widget> _screens = [
    ProfileScreen(),
    ListChatScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
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
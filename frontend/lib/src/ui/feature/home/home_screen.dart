import 'package:flutter/material.dart';

import 'package:frontend/core/helpers/constants.dart';

import 'package:frontend/features/conversation/presentation/pages/list_chat_screen.dart';
import 'package:frontend/src/ui/feature/profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex = 1;
  final List<Widget> _screens = [
    ProfileScreen(),
    ListChatScreen(),
    // SettingsScreen(),
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
      child: _screens[_selectedIndex]
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: AppColors.backgroundColor, 
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
  );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/core/services/token.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
      backgroundColor: AppColors.backgroundColor,
        title: const Center(child: Text('Settings'),),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Account Section
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.bookmark,
            title: 'Saved messages',
            onTap: () async {
              final _storage = TokenStorageService();
              final savedMessagesId = await _storage.getSavedMessages();
              if (savedMessagesId != null && savedMessagesId.isNotEmpty) {
                context.push(
                  "/chat-page?id=$savedMessagesId&mate=Saved%20Messages"
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No saved messages found')),
                );
              }
            },
          ),
          _SettingsTile(
            icon: Icons.call,
            title: 'Recent calls',
            onTap: () async {
              final _storage = TokenStorageService();
              final userId = _storage.getUserId();
              context.push(
                "/recent-call"
              );
            },
          ),
          _SettingsTile(
            icon: Icons.folder,
            title: 'Chat folders',
            onTap: () {
              // Navigate to chat folders
            },
          ),
          const Divider(),

          // App Settings Section
          const _SectionHeader(title: 'App Settings'),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications and sounds',
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          _SettingsTile(
            icon: Icons.palette,
            title: 'Appearance',
            onTap: () {
              // Navigate to appearance settings
            },
          ),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            onTap: () {
              // Navigate to language settings
            },
          ),
          const Divider(),

          // Logout Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Show logout confirmation dialog
                _showLogoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                foregroundColor: Colors.red,
              ),
              child: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.of(context).pop();
            },
            child: const Text('Cancel',style: TextStyle(color: AppColors.primaryColor),),
          ),
          TextButton(
            onPressed: () {
              // Perform logout
              context.go("/splash");
            },
            child: const Text('Log out',style: TextStyle(color: AppColors.primaryColor),),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
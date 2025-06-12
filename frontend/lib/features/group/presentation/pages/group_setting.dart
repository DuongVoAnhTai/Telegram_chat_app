import 'package:flutter/material.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:go_router/go_router.dart';

class GroupSettingPage extends StatefulWidget {
  final String conversationId;
  GroupSettingPage({required this.conversationId});
  @override
  _GroupSettingPageState createState() => _GroupSettingPageState();
}
class _GroupSettingPageState extends State<GroupSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Group Settings'),
      ),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.add_circle_rounded,  
            title: "Add Member", 
            onTap: () {
              context.push(
                "/add-member-page?conversationId=${widget.conversationId}"
              );
            },
          ),
          _SettingsTile(
            icon: Icons.remove_circle_rounded,
            title: "Remove Member",
            onTap: () {
              context.push(
                "/remove-member-page?conversationId=${widget.conversationId}"
              );
            },
          ),
          _SettingsTile(
            icon: Icons.change_circle_outlined,
            title: "Change name group",
            onTap: () {
              _showGroupNameDialog();
            },
          ),
        ],
      )
       
    );
  }
    Future<void> _showGroupNameDialog() async {
    String groupName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Enter Group Name', style: TextStyle(color: AppColors.textPrimary)),
          content: TextField(
            onChanged: (value) {
              groupName = value;
            },
            decoration: const InputDecoration(hintText: 'Group name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
            ),
            TextButton(
              onPressed: () {
                if (groupName.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name cannot be empty')),
                  );
                  return;
                }
                
                Navigator.of(context).pop(groupName);
              },
              child: const Text('OK', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        );
      },
    );

    if (groupName.trim().isNotEmpty) {
      try {
        // await _apiService.createGroup(groupName, selectedIds, widget.currentUserId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "$groupName" change successfully')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $error')),
        );
      }
    }
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
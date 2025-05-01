import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/theme/theme.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_state.dart';

// User class with better documentation and structure
class User {
  final String name;
  final String initial; // First character for CircleAvatar display
  final String? lastMessage;
  final DateTime? lastMessageTime;

  User({
    required this.name,
    required this.initial,
    this.lastMessage,
    this.lastMessageTime,
  });
}

class ListChatScreen extends StatefulWidget {
  const ListChatScreen({Key? key}) : super(key: key);

  @override
  State<ListChatScreen> createState() => _ListChatScreenState();
}

class _ListChatScreenState extends State<ListChatScreen> {
  // Sample user data
  final List<User> _allUsers = [
    User(
      name: "User 1",
      initial: "U",
      lastMessage: "Hello there!",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    User(
      name: "User 2",
      initial: "U",
      lastMessage: "When will you be available?",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    User(
      name: "User 3",
      initial: "U",
      lastMessage: "Thanks for your help",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    User(
      name: "User 4",
      initial: "U",
      lastMessage: "See you tomorrow",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
    _searchController.addListener(_filterUsers);
    BlocProvider.of<ConversationBloc>(context).add(FetchConversations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers =
          _allUsers
              .where((user) => user.name.toLowerCase().contains(query))
              .toList();
    });
  }

  String _formatLastMessageTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Search bar with improved styling
          // Padding(
          //   padding: const EdgeInsets.all(AppSizes.padding),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: InputDecoration(
          //       hintText: "Search users...",
          //       prefixIcon: const Icon(
          //         Icons.search,
          //         color: AppColors.primaryColor,
          //       ),
          //       filled: true,
          //       fillColor: AppColors.white,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          //         borderSide: BorderSide.none,
          //       ),
          //       contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          //       suffixIcon:
          //           _searchController.text.isNotEmpty
          //               ? IconButton(
          //                 icon: const Icon(Icons.clear),
          //                 onPressed: () {
          //                   _searchController.clear();
          //                 },
          //               )
          //               : null,
          //     ),
          //   ),
          // ),

          // Empty state
          // if (_filteredUsers.isEmpty)
          //   Expanded(
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          //           const SizedBox(height: 16),
          //           Text(
          //             "No users found",
          //             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),

          // Chat list with improved styling
          // if (_filteredUsers.isNotEmpty)
          //   Expanded(
          //     child: ListView.separated(
          //       itemCount: _filteredUsers.length,
          //       separatorBuilder: (context, index) => const Divider(height: 1),
          //       itemBuilder: (context, index) {
          //         final user = _filteredUsers[index];
          //         return ListTile(
          //           leading: CircleAvatar(
          //             backgroundColor: AppColors.primaryColor,
          //             child: Text(
          //               user.initial,
          //               style: const TextStyle(color: AppColors.white),
          //             ),
          //           ),
          //           title: Text(
          //             user.name,
          //             style: const TextStyle(
          //               color: AppColors.textPrimary,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           subtitle:
          //               user.lastMessage != null
          //                   ? Text(
          //                     user.lastMessage!,
          //                     maxLines: 1,
          //                     overflow: TextOverflow.ellipsis,
          //                     style: TextStyle(color: Colors.grey[600]),
          //                   )
          //                   : null,
          //           trailing:
          //               user.lastMessageTime != null
          //                   ? Text(
          //                     _formatLastMessageTime(user.lastMessageTime),
          //                     style: TextStyle(
          //                       color: Colors.grey[500],
          //                       fontSize: 12,
          //                     ),
          //                   )
          //                   : null,
          //           onTap: () {
          //             // Navigate to chat screen
          //             print("Starting chat with ${user.name}");
          //           },
          //         );
          //       },
          //     ),
          //   ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: BlocBuilder<ConversationBloc, ConversationState>(
                builder: (context, state) {
                  if (state is ConversationLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ConversationLoaded) {
                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder:
                            //         (context) => ChatPage(
                            //           conversationId: conversation.id,
                            //           mate: conversation.participantName,
                            //         ),
                            //   ),
                            // );
                            context.go(
                              "/chat-page?id=${conversation.id}&mate=${conversation.participantName}",
                            );
                          },
                          child: _buildMessageTile(
                            conversation.participantName,
                            conversation.lastMessage,
                            conversation.lastMessageTime.toString(),
                          ),
                        );
                      },
                    );
                  } else if (state is ConversationError) {
                    return Center(
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  } else {
                    return Text(
                      'No conversations found',
                      style: TextStyle(color: Colors.black),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: const Icon(FontAwesomeIcons.plus),
        onPressed: () {
          // Navigate to new chat screen
          print("Create new chat");
        },
      ),
    );
  }

  Widget _buildMessageTile(String name, String message, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        child: Text(
          name[0][0].toUpperCase(),
          style: const TextStyle(color: AppColors.white),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(time, style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildRecentContact(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "https://asset.brandfetch.io/id1t-fbPVK/idSLhuZ0RF.png?updated=1635888650006",
            ),
          ),
          SizedBox(height: 5),
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

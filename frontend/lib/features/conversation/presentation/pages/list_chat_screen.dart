import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/core/navigation/routers.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';

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

class _ListChatScreenState extends State<ListChatScreen> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  List<ConversationEntity> _filteredConversations = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterConversations);
    BlocProvider.of<ConversationBloc>(context).add(FetchConversations());
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
   @override
  void didPopNext() {
    // Gọi lại khi từ trang khác pop về đây
    BlocProvider.of<ConversationBloc>(context).add(FetchConversations());
  }
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  
  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search conversations...",
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryColor,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
              ),
            ),
          ),

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
                    // Filter conversations based on search query
                    _filteredConversations =
                        _isSearching
                            ? state.conversations
                                .where(
                                  (conversation) =>
                                      conversation.conversationName
                                          .toLowerCase()
                                          .contains(
                                            _searchController.text
                                                .toLowerCase(),
                                          ) ||
                                      conversation.lastMessage
                                          .toLowerCase()
                                          .contains(
                                            _searchController.text
                                                .toLowerCase(),
                                          ),
                                )
                                .toList()
                            : state.conversations;

                    if (_filteredConversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching
                                  ? "No conversations found"
                                  : "No conversations yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: _filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _filteredConversations[index];
                        return GestureDetector(
                          onTap: () async {
                            context.push(
                              "/chat-page?id=${conversation.id}&mate=${conversation.conversationName}&profilePic=${conversation.profilePic ?? ''}",
                            );
                          },
                          child: _buildMessageTile(
                            conversation.conversationName,
                            conversation.lastMessage,
                            _formatLastMessageTime(
                              conversation.lastMessageTime,
                            ),
                            conversation,
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
                    return Center(
                      child: Text(
                        'No conversations found',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'createGroup', // quan trọng nếu có nhiều FAB
            backgroundColor: Colors.green, // đổi màu nếu muốn
            child: const Icon(Icons.group_add),
            onPressed: () {
              context.push("/create-group-page"); // hoặc đường dẫn bạn muốn
            },
          ),
          const SizedBox(height: 12), // khoảng cách giữa 2 nút
          FloatingActionButton(
            heroTag: 'contactsButton',
            backgroundColor: AppColors.primaryColor,
            child: const Icon(Icons.contacts_outlined),
            onPressed: () {
              context.push("/contact-page");
            },
          ),
        ],
      ),

    );
  }

  Widget _buildMessageTile(
    String name,
    String message,
    String time,
    ConversationEntity conversation,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        backgroundImage:
            conversation.profilePic != null &&
                    conversation.profilePic!.isNotEmpty
                ? NetworkImage(conversation.profilePic!)
                : null,
        child:
            conversation.profilePic == null || conversation.profilePic!.isEmpty
                ? Text(
                  name[0][0].toUpperCase(),
                  style: const TextStyle(color: AppColors.white),
                )
                : null,
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

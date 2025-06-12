import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/helpers/constants.dart';
import 'package:frontend/features/conversation/domain/entities/conversation_entity.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:frontend/features/recentCallScreen/domain/entities/recentCall_entity.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_bloc.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_event.dart';
import 'package:frontend/features/recentCallScreen/presentation/bloc/recentCall_state.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

class RecentCallScreen extends StatefulWidget {
  const RecentCallScreen({Key? key}) : super(key: key);

    @override
  State<RecentCallScreen> createState() => _RecentCallScreen();
}
class _RecentCallScreen extends State<RecentCallScreen> {
  List<RecentCallEntity> recentCalls = [];
  List<ConversationEntity> conversations = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RecentCallBloc>(context).add(FetchRecentCalls());
    BlocProvider.of<ConversationBloc>(context).add(FetchConversations());
  }

  String _formatRecentCallTime(DateTime? time) {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: BlocBuilder<RecentCallBloc, RecentCallState>(
                builder: (context, recentCallState) {
                  return BlocBuilder<ConversationBloc, ConversationState>(
                    builder: (context, conversationState) {
                      if (recentCallState is RecentCallLoading || conversationState is ConversationLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (recentCallState is RecentCallLoaded && conversationState is ConversationLoaded) {
                        final recentCalls = recentCallState.recentCalls;
                        final conversations = conversationState.conversations;
                        return ListView.builder(
                          itemCount: recentCalls.length,
                          itemBuilder: (context, index) {
                            final recentCall = recentCalls[index];
                            final conversation = conversations.firstWhereOrNull(
                                (c) => c.id == recentCall.conversationId);
                            if (conversation == null) {
                              return SizedBox.shrink();
                            }
                            return GestureDetector(
                              onTap: () {
                                context.push(
                                  "/chat-page?id=${conversation.id}&mate=${conversation.conversationName}&profilePic=${conversation.profilePic ?? ''}",
                                );
                              },
                              child: _buildRecentTitle(
                                conversation.conversationName,
                                recentCall.callType,
                                _formatRecentCallTime(recentCall.endAt),
                                conversation,
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(child: Text('No recent calls available.'));
                      }
                    },
                  );
                },
              ),
            )
          )
        ],
      ),
    );
  }
  Widget _buildRecentTitle(String name, String callType, String endCallTime, ConversationEntity conversation) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        backgroundImage:
            conversation.profilePic != null
                ? NetworkImage(conversation.profilePic!)
                : null,
        child:
            conversation.profilePic == null
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
        callType,
        style: TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(endCallTime, style: TextStyle(color: Colors.grey)),
    );
  }
}
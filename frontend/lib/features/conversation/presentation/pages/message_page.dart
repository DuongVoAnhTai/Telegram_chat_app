import 'package:frontend/core/design_system/theme/theme.dart';
import 'package:frontend/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationBloc>(context).add(FetchConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages", style: Theme.of(context).textTheme.titleLarge),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0)),
          Text('Recent', style: Theme.of(context).textTheme.bodySmall),
          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContact("Brim", context),
                _buildRecentContact("Gekko", context),
                _buildRecentContact("Phoenix", context),
                _buildRecentContact("Reyna", context),
                _buildRecentContact("Chamber", context),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DefaultColors.messageListPage,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              // child: ListView(
              //   children: [
              //     _buildMessageTile('Lys', 'Làm tí Valorant', 'time'),
              //     _buildMessageTile('Tai', 'Làm tí Valorant', 'time'),
              //     _buildMessageTile('Trong', 'Làm tí Valorant', 'time'),
              //     _buildMessageTile('Son', 'Làm tí Valorant', 'time'),
              //   ],
              // ),
              child: BlocBuilder<ConversationBloc, ConversationState>(
                builder: (context, state) {
                  if (state is ConversationLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ConversationLoaded) {
                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return _buildMessageTile(
                          conversation.participantName,
                          conversation.lastMessage,
                          conversation.lastMessageTime.toString(),
                        );
                      },
                    );
                  } else if (state is ConversationError) {
                    return Center(child: Text('No conversations found'));
                  } else {
                    return Text('Nothing');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(String name, String message, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(
          "https://asset.brandfetch.io/id1t-fbPVK/idSLhuZ0RF.png?updated=1635888650006",
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

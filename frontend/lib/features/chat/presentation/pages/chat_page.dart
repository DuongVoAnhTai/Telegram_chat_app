import 'package:frontend/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/design_system/theme/theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  const ChatPage({required this.conversationId, required this.mate, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _storage = FlutterSecureStorage();
  String userId = '';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(
      context,
    ).add(LoadMessageEvent(widget.conversationId));
    fetchUserUI();
  }

  fetchUserUI() async {
    userId = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = userId;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<ChatBloc>(
        context,
      ).add(SendMessagesEvent(widget.conversationId, content));
    }
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                "https://asset.brandfetch.io/id1t-fbPVK/idSLhuZ0RF.png?updated=1635888650006",
              ),
            ),
            SizedBox(width: 10),
            Text(
              "${widget.mate}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ChatLoadedState) {
                  return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isSentMessage = message.senderId == userId;
                      if (isSentMessage) {
                        return _buildSentMessage(context, message.text);
                      } else {
                        return _buildReceivedMessage(context, message.text);
                      }
                    },
                  );
                } else if (state is ChatErrorState) {
                  return Center(child: Text(state.error));
                }
                return Center(child: Text("No messages found"));
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context, String mess) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 38, top: 5, bottom: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.receiverMessage,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(mess, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, String mess) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: 38, top: 5, bottom: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.receiverMessage,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(mess, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(25),
      ),
      margin: EdgeInsets.all(25),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(Icons.camera_alt, color: Colors.grey),
            onTap: () {},
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _messageController,
              // onSubmitted: (value) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Message",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            child: Icon(Icons.send, color: Colors.grey),
            onTap: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }
}

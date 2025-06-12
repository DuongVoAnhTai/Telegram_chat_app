import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chatbot_entity.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_event.dart';
import '../bloc/chatbot_state.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
        // At the bottom of the list, no action needed
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Text(
              'TLG ChatBot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatbotBloc, ChatbotState>(
                buildWhen: (previous, current) {
                  return current is ChatbotInitialState ||
                      current is ChatbotLoadedState ||
                      current is ChatbotLoadingState ||
                      current is ChatbotErrorState;
                },
                builder: (context, state) {
                  return _buildMessagesList(context, state);
                },
              ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatbotState state) {
    final messages = state is ChatbotLoadedState
        ? state.messages
        : state is ChatbotLoadingState
        ? state.messages
        : state is ChatbotErrorState
        ? state.messages
        : [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((state is ChatbotLoadedState || state is ChatbotLoadingState) && messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    if (state is ChatbotInitialState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy,
              size: 64,
              color: Colors.blueGrey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Bắt đầu cuộc trò chuyện với Gemini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[300],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatbotEntity message) {
    final isUserMessage = message.isUserMessage;
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.blueGrey[700],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: TextStyle(color: Colors.blueGrey[300]),
                border: InputBorder.none,
              ),
              onSubmitted: (value) => _sendMessage(context),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _messageController.text.trim().isEmpty
                  ? Colors.blueGrey[400]
                  : Colors.blueAccent,
            ),
            onPressed: () => _sendMessage(context),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatbotBloc>().add(SendMessageEvent(message));
      _messageController.clear();
      FocusScope.of(context).unfocus(); // Hide keyboard after sending
    }
  }
}
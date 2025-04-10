import 'package:flutter/material.dart';
import 'package:frontend/features/conversation_prev/page/chat_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;
  List<String> messages = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatService = ChatService();
    // Lấy tin nhắn cũ từ API
    chatService.fetchMessages().then((_) {
      setState(() {
        messages = chatService.messages;
      });
    });
    // Lắng nghe tin nhắn mới
    chatService.onMessageReceived((message) {
      setState(() {
        messages.add(message);
      });
    });
  }

  void sendMessage(String message) {
    chatService.sendMessage(message, 'User1');
    controller.clear();
  }

  @override
  void dispose() {
    chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Telegram Clone')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder:
                  (context, index) => ListTile(title: Text(messages[index])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      sendMessage(controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

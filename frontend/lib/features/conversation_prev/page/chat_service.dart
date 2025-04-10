import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  late IO.Socket socket;
  List<String> messages = [];

  ChatService() {
    // Đọc API_URL và SOCKET_URL từ file .env
    final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';
    final socketUrl = dotenv.env['SOCKET_URL'] ?? 'http://10.0.2.2:3000';

    // Kết nối socket.io
    socket = IO.io(
      socketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((_) {
      print('Connected to server');
    });
    socket.onDisconnect((_) => print('Disconnected'));
  }

  // Lấy tin nhắn cũ từ API
  Future<void> fetchMessages() async {
    try {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';
      final response = await http.get(Uri.parse('$apiUrl/api/messages'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        messages =
            data.map((msg) => '${msg['sender']}: ${msg['content']}').toList();
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  // Gửi tin nhắn qua Socket.IO
  void sendMessage(String message, String sender) {
    socket.emit('message', {'content': message, 'sender': sender});
  }

  // Đăng ký callback khi nhận tin nhắn mới
  void onMessageReceived(Function(String) callback) {
    socket.on('message', (data) {
      callback('${data['sender']}: ${data['content']}');
    });
  }

  // Ngắt kết nối khi không cần thiết
  void disconnect() {
    socket.disconnect();
  }
}

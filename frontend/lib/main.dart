import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/src/ui/feature/chat/chat_screen.dart';

Future<void> main() async {
  // Xác định đường dẫn thư mục gốc của project
  String projectRoot = Directory.current.path;
  
  // Load file .env từ thư mục gốc
  await dotenv.load(fileName: "$projectRoot/../.env");

  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}
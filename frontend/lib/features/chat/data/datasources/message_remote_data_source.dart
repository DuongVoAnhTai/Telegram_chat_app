import 'dart:convert';
import 'package:frontend/features/chat/domain/entities/message_entity.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/token.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  final String baseUrl = "http://192.168.137.1:3000/message";
  final _storage = TokenStorageService();

  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    final token = await _storage.getToken();
    print("After token: $token");
    final response = await http.get(
      Uri.parse('$baseUrl/$conversationId'),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print("data: $data");
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }
}

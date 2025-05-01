import 'dart:convert';

import 'package:frontend/core/services/token.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:http/http.dart' as http;

class ConversationRemoteDataSource {
  final String baseUrl = 'http://10.0.2.2:3000/conversation';
  final _storage = TokenStorageService();

  Future<List<ConversationModel>> fetchConversations() async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();
    final response = await http.get(
      Uri.parse('$baseUrl/fetchConversation/$userId'),
      headers: {"Authorization": "Bearer $token"},
    );
    print("userId: $userId");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }
}

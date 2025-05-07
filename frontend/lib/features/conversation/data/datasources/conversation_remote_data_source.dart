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
    print("userId: ");
    print(userId);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print(jsonEncode(data));

      List<ConversationModel> conversations = data.map((json) => ConversationModel.fromJson(json)).toList();

          // Tìm conversation có savedMessagesId và lưu xuống store
          for (var convo in conversations) {
            print(convo.savedMessagesId?? "DEO CO CAI CON ME GI HETTTTTTT");
            if (convo.savedMessagesId.isNotEmpty) {
          await _storage.saveSavedMessages(convo.savedMessagesId);
          break; // Nếu chỉ cần lưu một cái đầu tiên
        }
      }

      return conversations; 
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }

  Future<void> createConversations(String participantId) async {
    final token = await _storage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/createConversation'),
      body: jsonEncode({"participants": participantId}),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create conversations');
    }
  }

  Future<String> checkCreateConversation(String contactId) async {
    final token = await _storage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/checkOrCreate'),
      body: jsonEncode({"contactId": contactId}),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    print(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['_id'];
    } else {
      throw Exception('Failed to create conversations');
    }
  }
}

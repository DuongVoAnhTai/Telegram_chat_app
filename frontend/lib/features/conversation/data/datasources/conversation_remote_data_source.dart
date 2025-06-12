import 'dart:convert';

import 'package:frontend/core/services/token.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:http/http.dart' as http;

class ConversationRemoteDataSource {
  final String baseUrl = 'http://192.168.137.1:3000/conversation';
  final _storage = TokenStorageService();

  Future<List<ConversationModel>> fetchConversations() async {
    final token = await _storage.getToken();
    final userId = await _storage.getUserId();
    final response = await http.get(
      Uri.parse('$baseUrl/fetchConversation/$userId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print(jsonEncode(data));
      var names = "";
      for (var item in data) {
        final participants = item['participants'] as List<dynamic>;

        names = participants
            .where((p) => p['_id'] != userId)
            .map((p) => p['fullName'].toString())
            .join(", ");
      }

      // Convert to Future<List<ConversationModel>>
      List<Future<ConversationModel>> futures =
          data.map((json) => ConversationModel.fromJson(json, names)).toList();

      // Wait for all futures to complete
      List<ConversationModel> conversations = await Future.wait(futures);

      // Tìm conversation có savedMessagesId và lưu xuống store
      for (var convo in conversations) {
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
      Uri.parse('$baseUrl/create'),
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
  
  Future<void> createGroupChat(List<String> participantIds, String groupName) async {
    final token = await _storage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      body: jsonEncode({
        "participants": participantIds,
        "groupName": groupName,
        }),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create conversations');
    }
  }
  Future<void> addMemberToGroupChat(String conversationId, String newMemberId)
   async {
    print('Adding member to group chat: $conversationId, $newMemberId');
    final response = await http.post(
      Uri.parse('$baseUrl/addMember/$conversationId'),
      headers: {
        'Content-Type': 'application/json',
        // Thêm token nếu cần: 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "newMemberId": newMemberId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add member to group chat');
    }
  }
  Future<List<String>> getParticipants(String conversationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/getParticipants/$conversationId'),
      headers: {'Content-Type': 'application/json',},
      body: jsonEncode({"": ""}), // Body có thể để trống nếu không cần thiết
    );

    if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['participants']);
  } else {
    throw Exception('Failed to fetch participants: ${response.body}');
  }
  }
}

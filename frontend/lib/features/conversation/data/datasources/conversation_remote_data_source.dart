import 'dart:convert';

import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/conversation/data/models/conversation_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConversationRemoteDataSource {
  final String baseUrl = 'http://192.168.1.10:6000/message';
  final _storage = FlutterSecureStorage();

  Future<List<ConversationModel>> fetchConversations() async {
    // String token = await _storage.read(key: 'token') ?? '';
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2YwNWJjOGU5Mjc0YTZkN2RhZGQ5ZmEiLCJpYXQiOjE3NDQxOTIxOTAsImV4cCI6MTc0NDc5Njk5MH0.krO6dLTXjMsDnLv3QkVde7kPTJQqu8VWYLNVeWF8k9Y";
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }
}

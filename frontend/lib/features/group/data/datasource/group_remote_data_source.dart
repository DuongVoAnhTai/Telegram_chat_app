import 'dart:convert';

import 'package:frontend/core/services/token.dart';
import 'package:http/http.dart' as http;

class GroupRemoteDataSource {
  final String baseUrl = "http://192.168.137.1:3000/";
  final _storage = TokenStorageService();

  Future<Map<String, dynamic>> createGroup(
    String groupName,
    List<String> userIds,
  ) async {
    final currentUserId = await _storage.getUserId();
    final response = await http.post(
      Uri.parse('$baseUrl/group'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "groupName": groupName,
        "userIds": userIds,
        "currentUserId": currentUserId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create group');
    }
  }
}
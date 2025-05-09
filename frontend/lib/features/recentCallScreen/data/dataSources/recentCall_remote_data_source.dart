import 'dart:convert';

import 'package:frontend/features/recentCallScreen/data/models/recentCall_model.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/core/services/token.dart';

class RecentCallRemoteDataSource {
  final String baseUrl = 'http://10.0.2.2:3000/callLog';
  final _storage = TokenStorageService();

  Future<List<RecentCallModel>> fetchRecentCalls() async {
    // final token = await _storage.getToken();
    final userId = await _storage.getUserId();
    print("USER IDDDDDDDDDDDDDD: $userId");
    final response = await http.get(
      Uri.parse("$baseUrl/recentCall/$userId"),
      headers: {
        // "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      // Convert to List<Future<RecentCallModel>>
      print(jsonEncode(data));
      List<Future<RecentCallModel>> futures = 
      data.map((json) => RecentCallModel.fromJson(json)).toList();

      // Wait for all futures to complete
      List<RecentCallModel> recentcalls = await Future.wait(futures);
      return recentcalls;
    } else {
      throw Exception('Failed to fetch recent calls');
    }
  }

  // Gọi khi bắt đầu cuộc gọi
  Future<void> createRecentCall({
    required String conversationId,
    String callType = 'video',
  }) async {
    // final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    final body = jsonEncode({
      "userId": userId,
      "conversationId": conversationId,
      "callType": callType,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/start"),
      headers: {
        // "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create recent call');
    }
  }

  // Gọi khi kết thúc cuộc gọi
  Future<void> endRecentCall({
    required String conversationId,
  }) async {
    // final token = await _storage.getToken();
    final userId = await _storage.getUserId();

    final body = jsonEncode({
      "userId": userId,
      "conversationId": conversationId,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/end"),
      headers: {
        // "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to end recent call');
    }
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = "http://10.0.2.2:3000/auth";
  final _storage = FlutterSecureStorage();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    return UserModel.fromJson(jsonDecode(response.body));
  }

  Future<UserModel> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode({
        'fullName': fullname,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    return UserModel.fromJson(jsonDecode(response.body));
  }

  Future<UserModel> getUserProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      debugPrint('User profile response: $userData'); 
      return UserModel.fromJson({
        ...userData,
        'token': token,
      });
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get user profile');
    }
  }

  Future<UserModel> updateProfile({
    String? fullname,
    String? bio,
    DateTime? dob,
    String? profilePic,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final Map<String, dynamic> updateData = {};
    if (fullname != null) updateData['fullName'] = fullname;
    if (bio != null) updateData['bio'] = bio;
    if (dob != null) updateData['dob'] = dob.toIso8601String();
    if (profilePic != null) updateData['profilePic'] = profilePic;

    final response = await http.put(
      Uri.parse('$baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final updatedUserData = jsonDecode(response.body);
      return UserModel.fromJson({
        ...updatedUserData,
        'token': token,
      });
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update profile');
    }
  }
}

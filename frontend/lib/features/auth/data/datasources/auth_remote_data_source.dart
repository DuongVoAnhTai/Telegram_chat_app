import 'dart:convert';

import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = "http://192.168.1.11:6000/auth";

  Future<UserModel> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'password' : password}),
      headers: {'Content-Type': 'application/json'}
    );

    return UserModel.fromJson(jsonDecode(response.body));
  }

  Future<UserModel> register({required String fullname, required String email, required String password}) async {
    final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: jsonEncode({'fullName': fullname, 'email': email, 'password' : password}),
        headers: {'Content-Type': 'application/json'}
    );

    print("Result");
    print(response.body);

    return UserModel.fromJson(jsonDecode(response.body));
  }
}


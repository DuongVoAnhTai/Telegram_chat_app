import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/token.dart';
import '../models/contact_model.dart';

class ContactRemoteDataSource {
  final String baseUrl = 'http://192.168.137.1:3000/contact';
  final _storage = TokenStorageService();

  Future<List<ContactModel>> fetchContacts() async {
    final token = await _storage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/fetchContact'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ContactModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch contact');
    }
  }

  Future<void> addContact(String email) async {
    final token = await _storage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/addContact'),
      body: jsonEncode({"contactEmail": email}),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 404) {
      throw Exception('User not found');
    }

    if (response.statusCode != 201) {
      throw Exception('Failed to add contact');
    }
  }

  Future<void> deleteContact(String contactId) async {
    final token = await _storage.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$contactId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete contact');
    }
  }
}

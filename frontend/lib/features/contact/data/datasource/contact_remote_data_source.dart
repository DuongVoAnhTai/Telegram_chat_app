import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/token.dart';
import '../models/contact_model.dart';

class ContactRemoteDataSource {
  final String baseUrl = 'http://10.0.2.2:3000/contact';
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

  Future<void> addContact(String contactId) async {
    final token = await _storage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/addContact'),
      body: jsonEncode({"contactId": contactId}),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add contact');
    }
  }
}

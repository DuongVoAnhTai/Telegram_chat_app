import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class CloudinaryHelper {
  static const String baseUrl = "http://10.0.2.2:3000/auth";
  static final _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> getCloudinarySignature() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/cloudinary-signature'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get Cloudinary signature');
    }
  }

  static Future<String> uploadImage(File image) async {
    try {
      final signatureData = await getCloudinarySignature();
      final cloudName = signatureData['cloudName'];
      final apiKey = signatureData['apiKey'];
      final signature = signatureData['signature'];
      final timestamp = signatureData['timestamp'].toString();
      final publicId = signatureData['publicId'];

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['api_key'] = apiKey
            ..fields['timestamp'] = timestamp
            ..fields['signature'] = signature
            ..fields['folder'] = 'profile_pics'
            ..fields['public_id'] = publicId
            ..files.add(await http.MultipartFile.fromPath('file', image.path));

      print('UPLOAD REQUEST FIELDS: ${request.fields}');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && jsonResponse['secure_url'] != null) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception(
          'Failed to upload image: ${jsonResponse['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}

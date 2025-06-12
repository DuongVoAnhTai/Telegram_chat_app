import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/chatbot_entity.dart';
import '../models/chatbot_model.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class ChatbotRemoteDataSource {
  final String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  Future<ChatbotModel> sendMessage(String message, {required UserEntity user}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null) {
      throw Exception('Gemini API key not found in .env file');
    }

    String formattedDob = user.dob != null ? user.dob!.toIso8601String() : 'Not provided';

    print('Sending message to Gemini API: $message'); // Debugging
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Bạn là 1 AI ChatBot mang tên TLG ChatBot. Hãy trả lời dựa theo thông tin đã có về người hỏi. Hoặc nếu không có, hoặc phạm trù khác bạn có thể tùy theo ngữ cảnh mà trả lời.."
              },
              {"text": message},
              {
                "text": "User context: "
                    "Name=${user.fullname}, "
                    "Email=${user.email}, "
                    "DOB=${formattedDob}, "
                    "Bio=${user.bio}, "
                    "ProfilePic=${user.profilePic}, "
                    "UserId=${user.id}"
              }
            ]
          }
        ]
      }),
    );

    print('Gemini API response: ${response.body}'); // Debugging
    if (response.statusCode == 200) {
      return ChatbotModel.fromGeminiResponse(jsonDecode(response.body));
    } else {
      return ChatbotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Opps Gemini đang quá tải rồi",
      isUserMessage: false,
      timestamp: DateTime.now(),
    );
    }
  }
}

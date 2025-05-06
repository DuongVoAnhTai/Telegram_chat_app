import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  // 1. Tạo một instance của FlutterSecureStorage
  // `const` để đảm bảo chỉ có một instance được tạo nếu dùng theo cách này.
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;
  TokenStorageService._internal();

  final _storage = const FlutterSecureStorage();

  // 2. Định nghĩa một key cố định để lưu và đọc token
  // Sử dụng static const để dễ truy cập và tránh lỗi gõ sai.
  static const _tokenKey = 'token';
  static const _userIdKey = 'userId';
  static const _savedMessagesKey = 'savedMessages';
  // 3. Hàm để lưu token vào Secure Storage
  Future<void> saveToken(String token) async {
    try {
      // Ghi giá trị token vào storage với key đã định nghĩa
      await _storage.write(key: _tokenKey, value: token);
      print('Token saved successfully!'); // Log để kiểm tra
    } catch (e) {
      // Bắt lỗi nếu có vấn đề khi ghi (hiếm gặp nhưng nên có)
      print('Error saving token to secure storage: $e');
      // Bạn có thể ném (throw) một lỗi tùy chỉnh ở đây nếu cần xử lý ở lớp gọi
      // throw Exception('Failed to save token');
    }
  }

  // 4. Hàm để đọc token từ Secure Storage
  Future<String?> getToken() async {
    try {
      // Đọc giá trị từ storage bằng key đã định nghĩa
      final token = await _storage.read(key: _tokenKey);
      return token; // Trả về token nếu tìm thấy, hoặc null nếu không có
    } catch (e) {
      // Bắt lỗi nếu có vấn đề khi đọc
      print('Error reading token from secure storage: $e');
      return null; // Trả về null nếu có lỗi
    }
  }

  // 5. Hàm để xóa token khỏi Secure Storage (khi logout)
  Future<void> deleteToken() async {
    try {
      // Xóa giá trị khỏi storage bằng key đã định nghĩa
      await _storage.delete(key: _tokenKey);
      print('Token deleted successfully!'); // Log để kiểm tra
    } catch (e) {
      // Bắt lỗi nếu có vấn đề khi xóa
      print('Error deleting token from secure storage: $e');
      // throw Exception('Failed to delete token');
    }
  }

  Future<String?> getUserId() async {
    try {
      // Đọc giá trị từ storage bằng key đã định nghĩa
      final token = await _storage.read(key: _userIdKey);
      return token; // Trả về token nếu tìm thấy, hoặc null nếu không có
    } catch (e) {
      // Bắt lỗi nếu có vấn đề khi đọc
      print('Error reading token from secure storage: $e');
      return null; // Trả về null nếu có lỗi
    }
  }
  Future<void> saveSavedMessages(String savedMessages) async {
    try {
      // Ghi giá trị token vào storage với key đã định nghĩa
      await _storage.write(key: _savedMessagesKey, value: savedMessages);
      print('Saved messages saved successfully!'); // Log để kiểm tra
    } catch (e) {
      // Bắt lỗi nếu có vấn đề khi ghi (hiếm gặp nhưng nên có)
      print('Error saving saved messages to secure storage: $e');
      // Bạn có thể ném (throw) một lỗi tùy chỉnh ở đây nếu cần xử lý ở lớp gọi
      // throw Exception('Failed to save token');
    }
  }
  Future<String?> getSavedMessages() async {
    try {
      // Đọc giá trị từ storage bằng key đã định nghĩa
      final token = await _storage.read(key: _savedMessagesKey);
      return token; // Trả về token nếu tìm thấy, hoặc null nếu không có
    } catch (e) {
      // Bắt lỗi nếu có vấn đề khi đọc
      print('Error reading saved messages from secure storage: $e');
      return null; // Trả về null nếu có lỗi
    }
  }
}
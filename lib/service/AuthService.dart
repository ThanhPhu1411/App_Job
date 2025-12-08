import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://10.0.2.2:7044/api/AuthApi';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 🔥 Lưu token nếu có
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        print('✅ Token đã được lưu: ${data['token']}');
      }
      return data;
    } else {
      print('❌ Lỗi đăng nhập: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(String email, String password, String username) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password, 'username': username}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi đăng ký: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  // 🧠 Thêm hàm lấy token khi gọi API khác
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  Future<Map<String, dynamic>?> fetchProtectedData(String endpoint) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await client.get(
      Uri.parse('https://10.0.2.2:7044/api/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 Gửi token JWT ở đây
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi khi gọi API bảo vệ: ${response.statusCode}');
      return null;
    }
  }

}

import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
class NotificationService {
  final String baseUrl = 'https://10.0.2.2:7044/api/NotificationAPI';

  Future<Map<String, dynamic>?> fetchAll({int page = 1, int pageSize = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client
        .get(Uri.parse('$baseUrl/Index?page=$page&pageSize=$pageSize'),
         headers: {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer $token',
          },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(' Lỗi API: ${response.statusCode}');
      return null;
    }
  }
  Future<Map<String, dynamic>?> getDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client
        .get(Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      return null;
    }
  }
}

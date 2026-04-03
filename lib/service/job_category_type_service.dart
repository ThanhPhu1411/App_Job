import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class JobCategoryTypeService {
  final String baseUrl = 'https://10.0.2.2:7044/api/JobTypeCategorAPIControllercs';


  Future<List<dynamic>> getJobTypes() async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return [];
    }

    final response = await client.get(
      Uri.parse('$baseUrl/jobtypes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;  // ✅ trả về list
      return [];
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      return [];
    }
  }

  Future<List<dynamic>> getCategories() async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return [];
    }

    final response = await client.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;  // ✅ trả về list
      return [];
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      return [];
    }
  }
}
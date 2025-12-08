import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobserVice {
  final String baseUrl = 'https://10.0.2.2:7044/api/JobsApi';
  Future<Map<String, dynamic>?> getJobsAll() async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return null;
    }

    final response = await client.get(
      Uri.parse('$baseUrl/GetJobsAll'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 gửi token trong header
      },
    );

    if (response.statusCode == 200) {
      print("✅ Lấy danh sách công việc thành công!");
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      print('Phản hồi: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getJobs({int page = 1, int pageSize = 5}) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return null;
    }

    final response = await client.get(
      Uri.parse('$baseUrl?page=$page&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 gửi token trong header
      },
    );

    if (response.statusCode == 200) {
      print("✅ Lấy danh sách công việc thành công!");
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      print('Phản hồi: ${response.body}');
      return null;
    }
  }


  Future<Map<String, dynamic>?> getJobDetail(String jobId) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return null;
    }

    final response = await client.get(
      Uri.parse('$baseUrl/$jobId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 gửi token trong header
      },
    );

    if (response.statusCode == 200) {
      print("✅ Lấy danh sách công việc thành công!");
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      print('Phản hồi: ${response.body}');
      return null;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedJobService {
  final String baseUrl = 'https://10.0.2.2:7044/api/SavedJobsApi';


  Future<Map<String, dynamic>?> getSavedJobsAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // 🟢 Lấy token

    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.get(
      Uri.parse("$baseUrl/SavedJobsAll"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 🟢 Gửi token
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi api : ${response.statusCode}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSavedJobs({int page = 1, int pageSize = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.get(
      Uri.parse("$baseUrl/JobSaved?page=$page&pageSize=$pageSize"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Lỗi api : ${response.statusCode}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.post(
      Uri.parse('$baseUrl/SaveJob?jobId=$jobId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Bạn đã lưu công việc này rồi : ${response.statusCode}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> deleteSave(int saveJobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);
    print('🗑️ Gọi API xóa: $baseUrl/DeleteSavedJob?saveJobId=$saveJobId');

    final response = await client.delete(
      Uri.parse('$baseUrl/DeleteSavedJob?saveJobId=$saveJobId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));
    print('📥 Status code: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Không hủy được: ${response.statusCode}');
      return null;
    }
  }
}

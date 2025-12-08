import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ApplyJob{
  final String baseUrl = 'https://10.0.2.2:7044/api/ApplyApi';

  Future<Map<String, dynamic>?> applyJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.post(
      Uri.parse('$baseUrl/apply?jobId=$jobId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Bạn đã ứng tuyển công việc này rồi : ${response.statusCode}');
      return null;
    }
  }
}
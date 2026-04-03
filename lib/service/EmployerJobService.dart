import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployerJobService{
  final String baseUrl = 'https://10.0.2.2:7044/api/EmployerAPI';

  Future<Map<String, dynamic>?>getJobs (String filter) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host,
          int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return null;
    }

    final response = await client.get(
      Uri.parse('$baseUrl/index?filter=$filter'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 gửi token trong header
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // data['job'] chính là danh sách công việc
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      return null;
    }
  }


  Future<Map<String, dynamic>?>getJobDetail (String id) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host,
          int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return null;
    }

    final response = await client.get(
      Uri.parse('$baseUrl/id?id=$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 👈 gửi token trong header
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // data['job'] chính là danh sách công việc
    } else {
      print('❌ Lỗi API: ${response.statusCode}');
      return null;
    }
  }



  Future<bool> deleteJob(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print("❌ Chưa có token, vui lòng đăng nhập trước!");
      return false;
    }

    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final response = await client.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Xóa thất bại: ${response.statusCode} ${response.body}");
      return false;
    }
  }

  Future<String?> createJob(Map<String, Object> data) async {
    final ioc = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return null;

    final response = await client.post(
      Uri.parse("$baseUrl/add"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    print("📩 Server trả về: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      return result['id']?.toString();
    } else {
      print("Lỗi tạo hồ sơ: ${response.statusCode}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateJob(Map<String, Object> data, String jobId) async {
    final ioc = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return null;

    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/$jobId"));
    request.headers['Authorization'] = "Bearer $token";

// Thêm dữ liệu
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    var response = await client.send(request);
    var responseBody = await response.stream.bytesToString();

    print(" Server trả về: $responseBody");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Cập nhật công việc thành công");
      return json.decode(responseBody);
    } else {
      print(" Lỗi cập nhật công việc: ${response.statusCode}");
      return null;
    }
  }


}
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CompanyJobService {
  final String baseUrl = 'https://10.0.2.2:7044/api/JobPublicAPI';

  Future<Map<String, dynamic>?> fetchCompanyJobs(String employerId) async {
    //Flutter mặc định chỉ chấp nhận HTTPS với chứng chỉ hợp lệ.
    //Tạo client HTTP cho Dart/Flutter HttpClient
    //Khi gặp chứng chỉ HTTPS không tin cậy, callback này sẽ được gọi badCertificateCallback
    //(X509Certificate cert, String host, int port) => true Luôn trả true, tức là bỏ qua mọi cảnh báo chứng chỉ
    //Bao HttpClient thành IOClient để dùng với package http (giống http.post)
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
      Uri.parse('$baseUrl/$employerId'),
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


}
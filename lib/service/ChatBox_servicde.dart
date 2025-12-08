import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';


class ChatBox {
  final String baseUrl = 'https://10.0.2.2:7044/api/ChatBoxAPI';

  /// Gửi câu hỏi và lịch sử chat đến API
  ///
  /// [currentMessage] là tin nhắn mới của người dùng.
  /// [history] là danh sách các tin nhắn trước đó (List<Map<String, dynamic>>).
  Future<Map<String, dynamic>?> askJob(
      String currentMessage, List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    // --- THAY ĐỔI QUAN TRỌNG ---
    // 1. Chuyển đổi lịch sử Flutter (dùng 'isUser') sang định dạng API C# (dùng 'role')
    List<Map<String, String>> apiHistory = history.map((msg) {
      return {
        "role": (msg['isUser'] as bool) ? "user" : "model",
        "text": msg['text'] as String,
      };
    }).toList();

    // 2. Tạo đối tượng body khớp với 'AskRequest' của C#
    final requestBody = {
      "CurrentMessage": currentMessage,
      "History": apiHistory,
    };
    // --- KẾT THÚC THAY ĐỔI ---

    try {
      final response = await client
          .post(
        Uri.parse('$baseUrl/ask'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Đảm bảo utf-8
          'Authorization': 'Bearer $token',
        },
        // 3. Mã hóa đối tượng requestBody thành JSON
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 30)); // Tăng thời gian chờ

      if (response.statusCode == 200) {
        // Phải giải mã body bằng utf8 để hỗ trợ tiếng Việt
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('Lỗi server : ${response.statusCode}');
        print('Nội dung lỗi: ${response.body}');
        return {'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('Lỗi kết nối (timeout hoặc khác): $e');
      throw Exception('Không thể kết nối đến server: $e');
    } finally {
      client.close(); // Đóng client sau khi dùng
    }
  }
}

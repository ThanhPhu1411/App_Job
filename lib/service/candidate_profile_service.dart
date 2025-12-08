import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CandidateProfileService {
  final String baseUrl = 'https://10.0.2.2:7044/api/CandidateProfileAPI';

  // 🟩 Lấy thông tin hồ sơ cá nhân
  Future<Map<String, dynamic>?> getMyProfile() async {
    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print(" Chưa có token, vui lòng đăng nhập trước!");
      return null;
    }

    final response = await client.get(
      Uri.parse('$baseUrl/my-profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print(" Lấy hồ sơ thành công");
      return jsonDecode(response.body);
    } else {
      print("Lỗi lấy hồ sơ: ${response.statusCode}");
      return null;
    }
  }

  // 🟦 Thêm hồ sơ mới
  Future<String?> createProfile(Map<String, String> data, File? avatar) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return null;

    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/add"));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(data);
    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatarFile', avatar.path));
    }

    var response = await client.send(request);
    final body = await response.stream.bytesToString();
    print("📩 Server trả về: $body");
    if (response.statusCode == 200) {
      final result = jsonDecode(body);
      // Giả sử API trả về object { id: "xxx", ... }
      return result['id']?.toString();
    } else {
      print("Lỗi tạo hồ sơ: ${response.statusCode}");
      return null;
    }
  }


  Future<bool> updateProfile(Map<String, String> data, File? avatar) async {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print("⚠️ Chưa có token, vui lòng đăng nhập trước!");
      return false;
    }

    final id = data['id'];
    data.remove('id');

    print("🔹 Gửi request update profile với dữ liệu:");
    data.forEach((k, v) => print("  $k : $v"));
    print("🔹 Avatar path: ${avatar?.path}");
    print("🔹 URL: $baseUrl/update?id=$id");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/update?id=$id"),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // ✅ Đổi key sang PascalCase cho khớp model C#
    request.fields.addAll({
      'UserName': data['userName'] ?? '',
      'UserEmail': data['userEmail'] ?? '',
      'UserPhone': data['userPhone'] ?? '',
      'UserAddress': data['userAddress'] ?? '',
      'UserPosition': data['userPosition'] ?? '',
      'UserBirthDate': data['userBirthDate'] ?? '',
      'UserFacebook': data['userFacebook'] ?? '',
      'UserDesiredJob': data['userDesiredJob'] ?? '',
      'DesiredSalary': data['desiredSalary'] ?? '',
      'ExperienceYear': data['experienceYear'] ?? '',
      'Experience': data['experience'] ?? '',
      'CertificateYear': data['certificateYear'] ?? '',
      'CertificateName': data['certificateName'] ?? '',
      'PrizeYear': data['prizeYear'] ?? '',
      'PrizeDesc': data['prizeDesc'] ?? '',
      'Language': data['language'] ?? '',
      'SoftSkill': data['softSkill'] ?? '',
      'Interest': data['interest'] ?? '',
      'CareerObjective': data['careerObjective'] ?? '',
      'Education': data['education'] ?? '',
      'EducationYear': data['educationYear'] ?? '',
    });

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatarFile', avatar.path));
    } else {
      // 👇 Dòng này giúp tránh lỗi "avatarFile is required"
      request.fields['avatarFile'] = '';
    }

    var response = await client.send(request);

    final body = await response.stream.bytesToString();
    print("📩 Server trả về: $body");

    if (response.statusCode == 200) {
      print("✅ Cập nhật hồ sơ thành công");
      return true;
    } else {
      print("❌ Lỗi cập nhật hồ sơ: ${response.statusCode}");
      return false;
    }
  }



  // 🟥 Xóa hồ sơ
  Future<bool> deleteProfile(String profileId) async {
    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioc);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print(" Chưa có token, vui lòng đăng nhập trước!");
      return false;
    }

    final response = await client.delete(
      Uri.parse('$baseUrl/delete?id=$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print(" Xóa hồ sơ thành công");
      return true;
    } else {
      print(" Lỗi xóa hồ sơ: ${response.statusCode}");
      return false;
    }
  }
}

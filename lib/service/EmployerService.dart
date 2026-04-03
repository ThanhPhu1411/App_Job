  import 'dart:convert';
  import 'dart:io';
  import 'package:http/io_client.dart';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  class EmployerService{
    final String baseUrl = 'https://10.0.2.2:7044/api/EmployerJobAPI';
    Future<String?> createEmployer(Map<String, String> data, File? logoFile, File? licenseFile) async {
      final ioc = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      final client = IOClient(ioc);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return null;

      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/add"));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(data);

      if (logoFile != null) {
        request.files.add(await http.MultipartFile.fromPath('logoFile', logoFile.path)); // tên param đúng với IFormFile
         request.fields['CompanyLogo'] = logoFile.path.split('/').last; // tên file gán vào Employer.CompanyLogo
      }
      if (licenseFile != null) {
        request.files.add(await http.MultipartFile.fromPath('licenseFile', licenseFile.path));
         request.fields['LicenseDocument'] = licenseFile.path.split('/').last;
      }

      var response = await client.send(request);
      final body = await response.stream.bytesToString();
      print("📩 Server trả về: $body");
      if (response.statusCode == 200) {
        final result = jsonDecode(body);
        return result['id']?.toString();
      } else {
        print("Lỗi tạo hồ sơ: ${response.statusCode}");
        return null;
      }
    }


    Future<String?> updateEmployer(Map<String, String> data, File? logoFile, File? licenseFile) async {
      final ioc = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      final client = IOClient(ioc);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return null;

      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/Update?id=${data['id']}"));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(data);

      if (logoFile != null) {
        request.files.add(await http.MultipartFile.fromPath('logoFile', logoFile.path)); // tên param đúng với IFormFile
   // tên file gán vào Employer.CompanyLogo
      }
      if (licenseFile != null) {
        request.files.add(await http.MultipartFile.fromPath('licenseFile', licenseFile.path));

      }

      var response = await client.send(request);
      final body = await response.stream.bytesToString();
      print("📩 Server trả về: $body");
      if (response.statusCode == 200) {
        return "success";
      } else {
        print("Lỗi tạo hồ sơ: ${response.statusCode}");
        return null;
      }
    }

    Future<Map<String, dynamic>?>getJobsApplcaitons (String jobId,String filter) async {
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
        Uri.parse('$baseUrl/jobapplications?jobId=$jobId&filter=$filter'),
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

    Future<Map<String, dynamic>?>getCompany () async {
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
        Uri.parse('$baseUrl/MyCompanyStatus'),
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

    Future<Map<String, dynamic>?>getCandidateProfile (String jobId,String userId) async {
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
        Uri.parse('$baseUrl/CandidateProfile?jobId=$jobId&id=$userId'),
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


    Future<Map<String, dynamic>?> approveJob(String jobId, String userId) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final ioc = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final client = IOClient(ioc);

      final response = await client.post(
        Uri.parse('$baseUrl/Approve?jobId=$jobId&userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Lỗi API : ${response.statusCode}');
        return null;
      }
    }


    Future<Map<String, dynamic>?> reJectJob(String jobId, String userId) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final ioc = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final client = IOClient(ioc);

      final response = await client.post(
        Uri.parse('$baseUrl/Reject?jobId=$jobId&userId=$userId'), //
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Reject STATUS => ${response.statusCode}");
      print(" Reject BODY   => ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌Lỗi API : ${response.statusCode}');
        return null;
      }
    }


    Future<Map<String, dynamic>?> searchCandidates({
      String? keyword,
      String? location,
      String? skill,
      String? salary,
      String? education,
      String? experienceYear,
      String? experience,
      String? desiredJob,
      required String jobId
    }
        ) async {
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
        Uri.parse('$baseUrl/search?jobId=$jobId&keyword=$keyword&location=$location&skill=$skill&salary=$salary&education=$education&experienceYear=$experienceYear&experience=$experience&desiredJob=$desiredJob'),
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

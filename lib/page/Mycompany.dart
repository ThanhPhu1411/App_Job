import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webtimvieclam/page/educationJob.dart';
import 'package:webtimvieclam/page/skillJob.dart';
import 'package:webtimvieclam/service/EmployerService.dart';
import '../service/candidate_profile_service.dart';
import '../view/index.dart';
import 'CVPreviewPage.dart';
import 'EditProfile.dart';
import 'JobCriteriaPage.dart';
import 'MyJobpage.dart';
import 'UpdateCompany.dart';
import 'experienceJob.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class MyCompany extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyCompany();
}

class _MyCompany extends State<MyCompany> {
  final EmployerService _service = EmployerService();
  Map<String, dynamic>? profile;
  bool isLoading = true;
  double latitude = 0;
  double longitude = 0;

  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await _service.getCompany();
    setState(() {
      profile = data;
      isLoading = false;
      latitude = (profile!['latitude'] ?? 0) / 10000000;
      longitude = (profile!['longitude'] ?? 0) / 1000000;
      print('Lat: $latitude, Lng: $longitude');
    });
  }

  Map<String, dynamic> getStatusInfo(String? status) {
    switch (status) {
      case "pending":
        return {"text": "Đang chờ", "color": Colors.orange};
      case "approved":
        return {"text": "Đã duyệt", "color": Colors.green};
      case "rejected":
        return {"text": "Từ chối", "color": Colors.red};
      default:
        return {"text": "Không xác định", "color": Colors.grey};
    }
  }

  Future<void> _openMap() async {
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có vị trí để chỉ đường')),
      );
      return;
    }
    final zoomLevel = 30;
    // Link mở trên trình duyệt, không cần đăng nhập
    final googleUrl = Uri.parse(
      'https://www.google.com/maps?q=$latitude,$longitude',
    );

    try {
      await launchUrl(
        googleUrl,
        mode: LaunchMode.externalApplication, // luôn mở trên trình duyệt
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở bản đồ.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Công ty", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.deepPurple),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              width: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: profile?['companyLogo'] != null
                        ? NetworkImage(
                            "https://10.0.2.2:7044/images/${profile!['companyLogo']}",
                          )
                        : AssetImage("assets/default_avatar.png")
                              as ImageProvider,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile?['companyName'] ?? "Khong co cong ty",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusInfo(
                            profile?['status'] ?? "khong co trang thai",
                          )['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          getStatusInfo(profile?['status'])['text'] ??
                              "Khong co trang thai",
                          style: TextStyle(
                            color:
                                getStatusInfo(profile?['status'])['color'] ??
                                "khong co trang thai",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Column(
                    children: [
                      Text(
                        "Thông tin cơ bản",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.grey),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              profile?['companyEmail'] ?? "khong co email",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              profile?['companyAddress'] ?? 'Khong co dia chi',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.grey),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              profile?['companySize'] ?? 'Khong co Size',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Giấy phép kinh doanh",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              profile?["licenseDocument"] ??
                                  "Khong co giay phep",
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Giới thiệu về công ty",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        profile?['companyDescription'] ?? "khong co mieu ta",
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 12),

                      if (!isLoading && latitude != 0 && longitude != 0)
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(latitude, longitude),
                              initialZoom: 15, // zoom vừa đủ để thấy marker
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                subdomains: ['a', 'b', 'c', 'd'],
                                userAgentPackageName:
                                    'com.example.webtimvieclam',
                                retinaMode: true,
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(latitude, longitude),
                                    width: 60,
                                    height: 60,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C1BC8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _openMap,
                          child: Text(
                            "Coi bản đồ",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        Navigator.push(context,
        MaterialPageRoute(builder: (context)=> UpdateCompanyPage()));
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpdateCompanyPage()),
        );

        // Nếu có cập nhật thành công, reload dữ liệu
        if (updated == true) {
          setState(() => isLoading = true);
          await loadData();
        }

      },
        backgroundColor: Colors.white,
        child: Icon(Icons.edit_note),),

    );
  }
}

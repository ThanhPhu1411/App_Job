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
import 'experienceJob.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class AddCompanyPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AddCompanyPage ();

  
}

class _AddCompanyPage extends State<AddCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final EmployerService _employerService  = EmployerService();

  final companyName = TextEditingController();
  final companyEmail = TextEditingController();
  final companySize = TextEditingController();
  final companyAddress = TextEditingController();
  final companyDesciption = TextEditingController();

  File? logoFile;
  File? licenseFile;
  LatLng selectedLocation = LatLng(10.762622, 106.660172); // mặc : HCM
  final MapController _mapController = MapController(); // <-- thêm controller
  @override
  void dispose() {
    companyName.dispose();
    companyEmail.dispose();
    companySize.dispose();
    companyAddress.dispose();
    companyDesciption.dispose();
    super.dispose();
  }
  // Chọn logo (ảnh)
  Future<void> pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          logoFile = File(picked.path);
        });
      }
    } catch (e) {
      print("Lỗi: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
      });
    }
  }

// Chọn giấy phép (PDF)
  Future<void> pickLicense() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          licenseFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print("Lỗi: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi: $e")));
      });
    }
  }


  Future <void> submit() async{
    if (!_formKey.currentState!.validate()) return;
    final data = {
      "CompanyName" : companyName.text,
      "CompanySize": companySize.text,
      "CompanyDescription": companyDesciption.text,
      "CompanyEmail" : companyEmail.text,
      "CompanyAddress": companyAddress.text,
      "Latitude": selectedLocation.latitude.toString(),
      "Longitude": selectedLocation.longitude.toString(),
    };
    final createdId = await _employerService.createEmployer(data, logoFile, licenseFile);
    if(createdId!=null)
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tạo công ty thành công: ID $createdId")));
      }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tạo công ty")));
    }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm công ty"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller : companyName,
                      decoration: InputDecoration(
                        labelText: "Tên công ty",
                        hintText: "Nhập tên công ty",
                      ),
                      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                    ),
                    TextFormField(
                      controller : companyEmail,
                      decoration: InputDecoration(
                        labelText: "Email công ty",
                        hintText: "Nhập email công ty",
                      ),
                      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                    ),
                    TextFormField(
                      controller : companySize,
                      decoration: InputDecoration(
                        labelText: "Số lượng nhân viên",
                        hintText: "Nhập số lượng nhân viên ",
                      ),
                      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                    ),
                    TextFormField(
                      controller : companyDesciption,
                      decoration: InputDecoration(
                        labelText: "Giới thiệu công ty",
                        hintText: "Nhập giới thiệu công ty",
                      ),
                      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                    ),
                    TextFormField(
                      controller: companyAddress,
                      decoration: InputDecoration(
                        labelText: "Địa chỉ công ty",
                        hintText: "Nhập địa chỉ công ty",
                      ),
                      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                      onFieldSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          try {
                            var locations = await locationFromAddress(value);
                            if (locations.isNotEmpty) {
                              final latLng = LatLng(
                                locations.first.latitude,
                                locations.first.longitude,
                              );
                              setState(() {
                                selectedLocation = latLng;
                              });
                              _mapController.move(latLng, 19); // <-- nhảy map tới địa chỉ
                            }
                          } catch (e) {
                            print("Không tìm thấy địa chỉ: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Không tìm thấy địa chỉ")),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => pickLogo(), // <-- gọi hàm đúng cách
                          child: Text("Chọn logo công ty"),
                        ),
                        SizedBox(width: 10),
                        logoFile != null ? Text("Đã chọn") : Text("Chưa chọn")
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => pickLicense(), // <-- gọi hàm đúng cách
                          child: Text("Chọn giấy phép kinh doanh"),
                        ),
                        SizedBox(width: 10),
                        licenseFile != null ? Text("Đã chọn") : Text("Chưa chọn") // <-- sửa logoFile thành licenseFile
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400)),
                      clipBehavior: Clip.hardEdge,
                      child: FlutterMap(
                        mapController: _mapController, // <-- gán controller
                        options: MapOptions(
                          initialCenter: selectedLocation,
                          initialZoom: 19,
                          onTap: (tapPosition, latlng) {
                            setState(() => selectedLocation = latlng);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                            subdomains: ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.example.webtimvieclam',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: selectedLocation,
                                width: 60,
                                height: 60,
                                child: const Icon(
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
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C1BC8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: submit,
                        child: const Text("Lưu thông tin", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                  ],
                ))
          ],
        ),
      ),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}
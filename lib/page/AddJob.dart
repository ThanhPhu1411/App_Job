import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webtimvieclam/page/EmployerIndex.dart';
import 'package:webtimvieclam/page/educationJob.dart';
import 'package:webtimvieclam/page/skillJob.dart';
import 'package:webtimvieclam/service/EmployerJobService.dart';
import 'package:webtimvieclam/service/EmployerService.dart';
import 'package:webtimvieclam/service/job_category_type_service.dart';
import '../service/candidate_profile_service.dart';
import '../view/index.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

class AddJob extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> _AddJob ();


}

class _AddJob  extends State<AddJob>{
  final _formKey = GlobalKey<FormState>();
  final EmployerJobService _employerJobService = EmployerJobService();
  final JobCategoryTypeService _jobCategoryTypeService= JobCategoryTypeService();

  final jobTitle = TextEditingController();
  final jobDesciption = TextEditingController();
  final jobRequirements = TextEditingController();
  final jobSalary = TextEditingController();
  final jobBenefits = TextEditingController();
  final jobLocation = TextEditingController();
  final jobDeadling = TextEditingController();
  final jobCategory = TextEditingController();
  final jobType = TextEditingController();
  String? selectedCategory;
  String? selectedJobType;
  bool isLoading = true;
  List<dynamic> categories = [];
  List<dynamic> jobTypes = [];

  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }
  Future loadDropdownData() async {
    try {
      final cats = await _jobCategoryTypeService.getCategories();
      final types = await _jobCategoryTypeService.getJobTypes();

      print('Categories : $cats'); // log ra đây
      print('JobTypes : $types');   // log ra đây

      setState(() {
        categories = cats;
        jobTypes = types;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('❌ Lỗi load dropdown: $e');
    }
  }

  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      jobDeadling.text = date.toIso8601String();
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    print("Selected category: $selectedCategory");
    print("Selected job type: $selectedJobType");
    final data = {
      "jobTitle": jobTitle.text,
      "jobDescription": jobDesciption.text,
      "requirements": jobRequirements.text,
      "salary": jobSalary.text,
      "benefits": jobBenefits.text,
      "locate": jobLocation.text,
      "applicationDeadline": jobDeadling.text,
      "categoryId": int.parse(selectedCategory!),
      "jobTypeId": int.parse(selectedJobType!),

    };

    final jobId = await _employerJobService.createJob(data);
    if (jobId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tạo công việc thành công: ID $jobId")));
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => EmployerIndex()
      ),);
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tạo công việc")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm công việc"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ) ,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key:_formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: jobTitle,
                    decoration: InputDecoration(
                      labelText: "Thêm công việc",
                      hintText: "Nhập công việc"
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),
                  TextFormField(
                    controller: jobDesciption,
                    decoration: InputDecoration(
                        labelText: "Thêm miêu tả công việc",
                        hintText: "Nhập miêu tả công việc"
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),
                  TextFormField(
                    controller: jobRequirements,
                    decoration: InputDecoration(
                        labelText: "Thêm yêu cầu công việc",
                        hintText: "Nhập yêu cầu công việc"
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),
                  TextFormField(
                    controller: jobSalary,
                    decoration: InputDecoration(
                        labelText: "Thêm lương",
                        hintText: "Nhập lương"
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),

                  TextFormField(
                    controller: jobBenefits,
                    decoration: InputDecoration(
                        labelText: "Quyền lơi",
                        hintText: "Nhập quyền lợi"
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),

                  TextFormField(
                    controller: jobLocation,
                    decoration: InputDecoration(
                        labelText: "Địa điểm",
                        hintText: "Nhập địa điểm làm việc"
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),
                   DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: "Ngành nghề"),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat["id"].toString(),
                        child: Text(cat["name"]),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedCategory = v),
                    validator: (v) => v == null ? "Chọn ngành nghề" : null,
                  ),

                  DropdownButtonFormField<String>(
                    value: selectedJobType,
                    decoration: InputDecoration(labelText: "Loại công việc"),
                    items: jobTypes.map((cat) {
                      return DropdownMenuItem(
                        value: cat["id"].toString(),
                        child: Text(cat["jobType_Name"]),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedJobType = v),
                    validator: (v) => v == null ? "Chọn loại công việc" : null,
                  ),

                  SizedBox(height: 16),
                  TextFormField(
                    controller: jobDeadling,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Hạn nộp hồ sơ",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: pickDate, validator: (v) => v!.isEmpty ? "Chọn ngày" : null,
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
                          child: Text("Thêm công việc",
                              style: TextStyle(color: Colors.white)),
                  )
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
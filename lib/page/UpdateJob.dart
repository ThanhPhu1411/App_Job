import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/service/EmployerJobService.dart';
import 'package:webtimvieclam/service/job_category_type_service.dart';

class UpdateJob extends StatefulWidget {
  final String jobId;

  const UpdateJob({Key? key, required this.jobId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UpdateJob();
}

class _UpdateJob extends State<UpdateJob> {
  final _formKey = GlobalKey<FormState>();
  final EmployerJobService _employerJobService = EmployerJobService();
  final JobCategoryTypeService _jobCategoryTypeService =
      JobCategoryTypeService();

  final jobTitle = TextEditingController();
  final jobDesciption = TextEditingController();
  final jobRequirements = TextEditingController();
  final jobSalary = TextEditingController();
  final jobBenefits = TextEditingController();
  final jobLocation = TextEditingController();
  final jobDeadling = TextEditingController();

  String? selectedCategory;
  String? selectedJobType;
  bool isLoading = true;
  List<dynamic> categories = [];
  List<dynamic> jobTypes = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    // Load dropdown trước
    await loadDropdownData();
    // Sau đó load chi tiết công việc
    await _loadProfile();
  }

  Future<void> loadDropdownData() async {
    try {
      final cats = await _jobCategoryTypeService.getCategories();
      final types = await _jobCategoryTypeService.getJobTypes();

      setState(() {
        categories = cats;
        jobTypes = types;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Lỗi load dropdown: $e');
    }
  }

  Future<void> _loadProfile() async {
    final data = await _employerJobService.getJobDetail(widget.jobId);
    if (data != null) {
      setState(() {
        jobTitle.text = data['jobTitle'] ?? '';
        jobDesciption.text = data['jobDescription'] ?? '';
        jobRequirements.text = data['requirements'] ?? '';
        jobSalary.text = data['salary'] ?? '';
        jobBenefits.text = data['benefits'] ?? '';
        jobLocation.text = data['locate'] ?? '';
        jobDeadling.text = data['applicationDeadline'] ?? '';
        selectedCategory = data['categoryId']?.toString();
        selectedJobType = data['jobTypeId']?.toString();
      });
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
      "id": widget.jobId,
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

    final updatedJob = await _employerJobService.updateJob(data, widget.jobId);

    if (updatedJob != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật công việc thành công!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật thất bại")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Chỉnh sửa công việc"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chỉnh sửa công việc"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: jobTitle,
                decoration: InputDecoration(
                  labelText: "Công việc",
                  hintText: "Nhập công việc",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: jobDesciption,
                decoration: InputDecoration(
                  labelText: "Miêu tả công việc",
                  hintText: "Nhập miêu tả công việc",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: jobRequirements,
                decoration: InputDecoration(
                  labelText: "Yêu cầu công việc",
                  hintText: "Nhập yêu cầu công việc",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: jobSalary,
                decoration: InputDecoration(
                  labelText: "Lương",
                  hintText: "Nhập lương",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: jobBenefits,
                decoration: InputDecoration(
                  labelText: "Quyền lợi",
                  hintText: "Nhập quyền lợi",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: jobLocation,
                decoration: InputDecoration(
                  labelText: "Địa điểm",
                  hintText: "Nhập địa điểm làm việc",
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
                onTap: pickDate,
                validator: (v) => v!.isEmpty ? "Chọn ngày" : null,
              ),
              SizedBox(height: 20),
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
                  onPressed: submit,
                  child: Text(
                    "Cập nhật công việc",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

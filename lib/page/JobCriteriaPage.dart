import 'dart:io';
import 'package:flutter/material.dart';
import '../service/candidate_profile_service.dart';
import 'CVPreviewPage.dart';

class Jobcriteriapage extends StatefulWidget {

  @override
  State<Jobcriteriapage> createState() => _Jobcriteriapage();
}

class _Jobcriteriapage extends State<Jobcriteriapage> {
  final _formKey = GlobalKey<FormState>();
  final _service = CandidateProfileService();
  final _careerObjectiveController = TextEditingController();
  final _desiredSalarylController = TextEditingController();
  final _userDesiredJobphoneController = TextEditingController();


  String? _profileId;
  bool _isLoading = true;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _service.getMyProfile();
    if (data != null) {
      setState(() {
        _profileId = data['id']?.toString();
        _careerObjectiveController.text = data['careerObjective'] ?? '';
        _desiredSalarylController.text = data['desiredSalary'] ?? '';
        _userDesiredJobphoneController.text = data['userDesiredJob'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'id': _profileId ?? '',
      'careerObjective': _careerObjectiveController.text,
      'desiredSalary': _desiredSalarylController.text,
      'userDesiredJob': _userDesiredJobphoneController.text,

    };
    if(_profileId == null){
      if (_avatarFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn ảnh đại diện trước khi tạo hồ sơ")),
        );
        return;
      }
      final created  = await _service.createProfile(data, _avatarFile);
      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo hồ sơ thành công!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi cập nhật, vui lòng thử lại!")),
        );
      }
    }
    else{
      final success = await _service.updateProfile({
        'id': _profileId!,
        ...data,
      }, _avatarFile);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật hồ sơ thành công!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi cập nhật, vui lòng thử lại!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tiêu chí tìm việc"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Mục tiêu nghề nghiệp", _careerObjectiveController, requiredField: true),
              const SizedBox(height: 16),
              _buildTextField("Mức lương mong muốn", _desiredSalarylController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Công việc mong muốn", _userDesiredJobphoneController,requiredField : true),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C1BC8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveProfile,
                  child: const Text("Lưu thông tin", style: TextStyle(color: Colors.white)),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextField(String label, TextEditingController controller, {bool requiredField = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: requiredField ? "$label *" : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      ),
      validator: (value) {
        if (requiredField && (value == null || value.isEmpty)) {
          return "Vui lòng nhập $label";
        }
        return null;
      },
    );
  }
// chọn ngày
}

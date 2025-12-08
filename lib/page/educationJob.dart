import 'dart:io';
import 'package:flutter/material.dart';
import '../service/candidate_profile_service.dart';
import 'CVPreviewPage.dart';

class Educationjob extends StatefulWidget {
  @override
  State<Educationjob> createState() => _Educationjob();
}

class _Educationjob extends State<Educationjob> {
  final _formKey = GlobalKey<FormState>();
  final _service = CandidateProfileService();
  final _educationController = TextEditingController();
  final _educationYearController = TextEditingController();
  final _userPositionController = TextEditingController();


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
        _educationController.text = data['education'] ?? '';
        _educationYearController.text = data['educationYear'] ?? '';
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
      'education': _educationController.text,
      'educationYear': _educationYearController.text,
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
        title: const Text("Trình độ học vấn "),
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
              _buildTextField("Tên trường học", _educationController, requiredField: true),
              const SizedBox(height: 16),
              _buildTextField("Năm tốt nghiệp", _educationYearController,requiredField : true),
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

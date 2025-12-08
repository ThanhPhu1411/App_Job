import 'dart:io';
import 'package:flutter/material.dart';
import '../service/candidate_profile_service.dart';
import 'CVPreviewPage.dart';

class Skilljob extends StatefulWidget {
  @override
  State<Skilljob> createState() => _Skilljob();
}

class _Skilljob extends State<Skilljob> {
  final _formKey = GlobalKey<FormState>();
  final _service = CandidateProfileService();
  final _certificateNameController = TextEditingController();
  final _certificateYearController = TextEditingController();
  final _prizeDescController = TextEditingController();
  final _prizeYearController = TextEditingController();
  final _languageController = TextEditingController();
  final _softSkillController = TextEditingController();



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
        _certificateNameController.text = data['certificateName'] ?? '';
        _certificateYearController.text = data['certificateYear'] ?? '';
        _prizeDescController.text = data['prizeDesc'] ?? '';
        _prizeYearController.text = data['prizeYear'] ?? '';
        _languageController.text = data['language'] ?? '';
        _softSkillController.text = data['softSkill'] ?? '';
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
      'certificateName': _certificateNameController.text,
      'certificateYear': _certificateYearController.text,
      'prizeDesc': _prizeDescController.text,
      'prizeYear': _prizeYearController.text,
      'language': _languageController.text,
      'softSkill': _softSkillController.text,
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
        title: const Text("Kỹ năng làm việc"),
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
              _buildTextField("Tên chứng trỉ", _certificateNameController, requiredField: true),
              const SizedBox(height: 16),
              _buildTextField("Năm cấp chứng trỉ", _certificateYearController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Giải thưởng", _prizeDescController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Năm cấp giải thưởng", _prizeYearController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Ngôn ngữ", _languageController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Kỹ năng mềm", _softSkillController,requiredField : true),
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

import 'dart:io';
import 'package:flutter/material.dart';
import '../service/candidate_profile_service.dart';
import 'CVPreviewPage.dart';

class EditProfilePage extends StatefulWidget {
  final String profileId;
  const EditProfilePage ({Key? key, required this.profileId}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = CandidateProfileService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _facebookController = TextEditingController();
  final _interestController = TextEditingController();


  String? _profileId;
  File? _avatarFile;
  bool _isLoading = true;

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
        _nameController.text = data['userName'] ?? '';
        _emailController.text = data['userEmail'] ?? '';
        _phoneController.text = data['userPhone'] ?? '';
        _addressController.text = data['userAddress'] ?? '';
        _facebookController.text = data['userFacebook'] ?? '';
        _dobController.text = _formatDate(data['userBirthDate']);
        _interestController.text = data['interest'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'id': _profileId ?? '',
      'userName': _nameController.text,
      'userEmail': _emailController.text,
      'userPhone': _phoneController.text,
      'userAddress': _addressController.text,
      'userBirthDate': _dobController.text,
      'userFacebook': _facebookController.text,
      'interest': _interestController.text,
      'userPosition': '',
      'userDesiredJob': '',
      'desiredSalary': '',
      'experienceYear': '',
      'experience': '',
      'certificateYear': '',
      'certificateName': '',
      'prizeYear': '',
      'prizeDesc': '',
      'language': '',
      'softSkill': '',
      'careerObjective': '',
      'education': '',
      'educationYear': '',
      'cvLayout': '1',
      'cvColorTheme': 'default',

    };

    final success = await _service.updateProfile(data, _avatarFile);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin cá nhân"),
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
              _buildTextField("Họ và tên", _nameController, requiredField: true),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Số điện thoại", _phoneController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Địa chỉ", _addressController,requiredField : true),
              const SizedBox(height: 16),
              _buildDateField("Ngày sinh", _dobController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Facebook", _facebookController,requiredField : true),
              const SizedBox(height: 16),
              _buildTextField("Sở thích cá nhân", _interestController,requiredField : true),
              const SizedBox(height: 30),
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
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PreviewCVPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6C1BC8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Xem trước CV", style: TextStyle(color: Color(0xFF6C1BC8))),
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
  Widget _buildDateField(String label, TextEditingController controller,{bool requiredField = false}) {
    return TextFormField(
      controller: controller,
      //người dùng không gõ tay được, chỉ chọn ngày.
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      //Khi nhấn vào (onTap), nó mở bảng chọn ngày (DatePicker).
      // Khi chọn xong, nó định dạng lại ngày và gán vào controller.text.
      onTap: () async {
        //Hàm showDatePicker() trả về ngày mà người dùng chọn, hoặc null nếu họ nhấn “Hủy”.
        DateTime? picked = await showDatePicker(
          context: context,
          //Ngày mặc định ban đầu khi mở lịch
          //Ở đây nếu controller.text (tức giá trị trong ô) có ngày hợp lệ thì dùng,
          // còn không thì dùng ngày hôm nay (DateTime.now()).
          initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          //Nếu người dùng chọn ngày, thì gán giá trị đó vào ô nhập (TextFormField).
          // Dòng này định dạng ngày về dạng "YYYY-MM-DD" — ví dụ:
          // Năm: picked.year
          // Tháng: picked.month.toString().padLeft(2, '0') → thêm số 0 nếu chỉ có 1 chữ số (5 → 05)
          // Ngày: picked.day.toString().padLeft(2, '0')
          controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      },
    );
  }
}

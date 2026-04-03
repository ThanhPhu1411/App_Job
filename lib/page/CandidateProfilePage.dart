import 'package:flutter/material.dart';
import 'package:webtimvieclam/service/EmployerService.dart';
import '../service/candidate_profile_service.dart';

class CandidateProfilePage extends StatefulWidget {
  @override
  final String jobId;
  final String profileId;

  const CandidateProfilePage({
    Key? key,
    required this.jobId,
    required this.profileId,
  }) : super(key: key);

  State<CandidateProfilePage> createState() => _CandidateProfilePage();
}

class _CandidateProfilePage extends State<CandidateProfilePage> {
  final _service = EmployerService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _service.getCandidateProfile(
      widget.jobId,
      widget.profileId,
    );
    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Xem CV ứng viên"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(child: Text("Không tìm thấy hồ sơ."))
          : LayoutBuilder(
              builder: (context, constraints) {
                // Kích thước CV gốc (tỉ lệ A4)
                const cvWidth = 800.0;
                const cvHeight = 1120.0;

                return Center(
                  // ✅ FittedBox tự co toàn bộ CV vừa màn hình (không cần cuộn)
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: cvWidth,
                      height: cvHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeftPanel(profile, 260),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                child: _buildRightPanel(profile),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final result = await _service.approveJob(
                    profile!['jobId'].toString(),
                    profile!['userID'].toString(),
                  );

                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(" Hồ sơ đã được duyệt")),

                    );

                    Navigator.pop(context, true); // quay về
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(" Duyệt thất bại")),
                    );
                  }
                },
                child: const Text(
                  "Duyệt hồ sơ",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final result = await _service.reJectJob(
                    profile!['jobId'].toString(),
                    profile!['userID'].toString(),
                  );

                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã từ chối hồ sơ")),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(" Từ chối thất bại")),
                    );
                  }
                },
                child: const Text(
                  "Từ chối",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel(Map<String, dynamic> profile, double width) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFF1d1d1d),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: profile['userAvatar'] != null
                ? NetworkImage(
                    "https://10.0.2.2:7044/images/${profile['userAvatar']}",
                  )
                : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
          ),
          const SizedBox(height: 20),
          Text(
            profile['userName'] ?? 'Chưa cập nhật',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            profile['userPosition'] ?? 'Sinh viên',
            style: const TextStyle(fontSize: 25, color: Color(0xFFFFA726)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          _buildLeftSection(
            title: "Liên hệ",
            children: [
              _infoLineIcon(
                Icon(Icons.phone, size: 22, color: Colors.blue),
                profile['userPhone'] ?? 'Chua co dien thoai',
              ),
              _infoLineIcon(
                Icon(Icons.email, size: 22, color: Colors.red),
                profile['userEmail'] ?? "Chua co face",
              ),
              _infoLineIcon(
                Icon(Icons.location_on, size: 22, color: Colors.green),
                profile['userAddress'] ?? "chua co dia chi",
              ),
              _infoLineIcon(
                Icon(Icons.facebook, size: 22, color: Colors.blueAccent),
                profile['userFacebook'] ?? "chua co face",
              ),
            ],
          ),

          const SizedBox(height: 25),
          _buildLeftSection(
            title: "Kỹ năng",
            children: [
              Text(
                "Ngoại ngữ: ${profile['language'] ?? 'Chưa cập nhật'}",
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
              Text(
                "Kỹ năng mềm: ${profile['softSkill'] ?? 'Chưa cập nhật'}",
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildLeftSection(
            title: "Sở thích",
            children: [
              Text(
                profile['interest'] ?? 'Chưa cập nhật',
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(Map<String, dynamic> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRightSection(
          "Mục tiêu nghề nghiệp",
          profile['careerObjective'] ?? "chua co",
        ),
        _buildRightSection(
          " Học vấn",
          "${profile['educationYear'] ?? ''} - ${profile['education'] ?? ''}",
        ),
        _buildRightSection(
          " Kinh nghiệm làm việc",
          "${profile['experienceYear'] ?? ''} - ${profile['experience'] ?? ''}",
        ),
        _buildRightSection(
          " Chứng chỉ",
          "${profile['certificateYear'] ?? ''} - ${profile['certificateName'] ?? ''}",
        ),
        _buildRightSection(
          " Giải thưởng",
          "${profile['prizeYear'] ?? ''} - ${profile['prizeDesc'] ?? ''}",
        ),
        _buildRightSection(
          " Công việc mong muốn",
          profile['userDesiredJob'] ?? "chua co",
        ),
        _buildRightSection(
          " Mức lương mong muốn",
          profile['desiredSalary'] ?? "chua co",
        ),
        _buildRightSection(
          " Thông tin khác",
          "Ngày sinh: ${profile['userBirthDate'] ?? 'Chưa cập nhật'}",
        ),
      ],
    );
  }

  Widget _infoLineIcon(Widget icon, String? info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info?.toString() ?? "Chưa cập nhật",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFA726),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        const Divider(color: Colors.white, thickness: 1),
        const SizedBox(height: 6),
        ...children
            .map(
              (e) =>
                  Padding(padding: const EdgeInsets.only(bottom: 5), child: e),
            )
            .toList(),
      ],
    );
  }

  Widget _buildRightSection(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content?.isNotEmpty == true ? content! : "Chưa cập nhật",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

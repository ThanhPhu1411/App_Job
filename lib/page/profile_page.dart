  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
  import 'package:webtimvieclam/page/educationJob.dart';
  import 'package:webtimvieclam/page/skillJob.dart';
  import '../service/candidate_profile_service.dart';
  import '../view/index.dart';
  import 'CVPreviewPage.dart';
  import 'EditProfile.dart';
  import 'JobCriteriaPage.dart';
  import 'MyJobpage.dart';
  import 'experienceJob.dart';
  import 'package:jwt_decoder/jwt_decoder.dart';

  class ProfilePage extends StatefulWidget {

    @override
    State<StatefulWidget> createState() => _ProfilePageState();
  }

  class _ProfilePageState extends State<ProfilePage> {
    final CandidateProfileService _candidateProfileService = CandidateProfileService();
    Map<String, dynamic>? profile;
    bool isLoading = true;
    File? _avatarFile;

    @override
    void initState() {
      super.initState();
      loadData();
    }

    Future<void> loadData() async {
      final data = await _candidateProfileService.getMyProfile(); // API trả JSON
      setState(() {
        profile = data;
        isLoading = false;
      });
    }

    /// 📸 Chọn ảnh và upload avatar, tạo hoặc cập nhật profile
    Future<void> _pickAvatar() async {
      try {
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked == null) return;

        File file = File(picked.path);
        setState(() {
          isLoading = true;
          _avatarFile = file; // Cập nhật avatar local để hiển thị ngay
        });

        // Lấy token từ SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Chưa đăng nhập")),
            );
          });
          return;
        }

        final decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

        if (userId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Không tìm thấy userID trong token")),
            );
          });
          return;
        }

        // Tạo Map dữ liệu profile, đảm bảo các cột NOT NULL luôn có giá trị rỗng nếu null
        Map<String, String> data = {
          'userName': profile?['userName'] ?? 'Chưa có tên',
          'userEmail': profile?['userEmail'] ?? 'Chưa có email',
          'userPhone': profile?['userPhone'] ?? 'Chưa có số điện thoại',
          'userAddress': profile?['userAddress'] ?? 'Chưa có địa chỉ',
          'userPosition': profile?['userPosition'] ?? 'Chưa có vị trí',
          'userBirthDate': profile?['userBirthDate'] ?? '2000-01-01',
          'userFacebook': profile?['userFacebook'] ?? 'Chưa có Facebook',
          'userDesiredJob': profile?['userDesiredJob'] ?? 'Chưa có công việc mong muốn',
          'desiredSalary': profile?['desiredSalary']?.toString() ?? '0',
          'experienceYear': profile?['experienceYear']?.toString() ?? '0',
          'experience': profile?['experience'] ?? 'Chưa có kinh nghiệm',
          'certificateYear': profile?['certificateYear']?.toString() ?? '0',
          'certificateName': profile?['certificateName'] ?? 'Chưa có chứng chỉ',
          'prizeYear': profile?['prizeYear']?.toString() ?? '0',
          'prizeDesc': profile?['prizeDesc'] ?? 'Chưa có giải thưởng',
          'language': profile?['language'] ?? 'Chưa có ngôn ngữ',
          'softSkill': profile?['softSkill'] ?? 'Chưa có kỹ năng mềm',
          'interest': profile?['interest'] ?? 'Chưa có sở thích',
          'careerObjective': profile?['careerObjective']?.toString() ?? 'Chưa có mục tiêu nghề nghiệp',
          'education': profile?['education'] ?? 'Chưa có học vấn',
          'educationYear': profile?['educationYear']?.toString() ?? '0',
          'userAvatar': file.path.split('/').last, // đảm bảo có avatar
        };

        // Nếu profile chưa có id → tạo mới
        if (profile == null || profile!['id'] == null) {
          final createdId = await _candidateProfileService.createProfile(data, file);
          if (createdId != null) {
            profile ??= {};
            profile!['id'] = createdId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tạo hồ sơ và cập nhật ảnh thành công!")),
              );
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Lỗi khi tạo hồ sơ và cập nhật ảnh")),
              );
            });
          }
        }
        // Nếu profile đã có id → cập nhật
        else {
          final ok = await _candidateProfileService.updateProfile({
            'id': profile!['id'].toString(),
            ...data,
          }, file);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ok ? "Cập nhật ảnh thành công" : "Lỗi khi cập nhật ảnh")),
            );
          });
        }

        // Load lại profile mới nhất
        await loadData();

      } catch (e) {
        print("Lỗi _pickAvatar: $e");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đã xảy ra lỗi: $e")),
          );
        });
      } finally {
        setState(() => isLoading = false);
      }
    }


    @override
    Widget build(BuildContext context) {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final name = profile?['userName'] ?? 'Chưa có tên';
      final email = profile?['userEmail'] ?? 'Chưa có email';
      final phone = profile?['userPhone'] ?? 'Chưa có số điện thoại';
      final avatarUrl = profile?['userAvatar'];

      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Cá nhân', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings, color: Colors.deepPurple),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- Thông tin cá nhân ---
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                width: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                        onTap: _pickAvatar, // Bấm vào avatar cũng mở chọn ảnh
                        child: CircleAvatar( // là widget dùng hiện thị ảnh hình trong
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : (avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage("https://10.0.2.2:7044/images/${profile?['userAvatar']}")
                              : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                        ),
                      ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: InkWell(
                            onTap: _pickAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.blue,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         SizedBox(height: 10),
                         Row(
                           children: [
                             Icon(Icons.phone,
                             size: 18, color:Colors.grey),
                             SizedBox(width: 4),
                             Text(
                               phone,
                               style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),
                             ),
                           ],
                         ),
                         SizedBox(height: 6),
                         Row(
                           children: [
                             Icon(Icons.email,
                                 size: 18, color:Colors.grey),
                             SizedBox(width: 4),
                             Text(
                               email,
                               style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),
                             ),
                           ],
                         ),
                         SizedBox(height: 10),
                         Row(
                           children: [
                             Icon(Icons.location_on,
                                 size: 18, color:Colors.grey),
                             SizedBox(width: 4),
                             Text(
                               profile?['userAddress'] ?? 'Khong co dia chi',
                               style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),
                               overflow: TextOverflow.ellipsis,
                               maxLines: 1,
                             ),

                           ],
                         ),
                         SizedBox(height: 10),
                         GestureDetector(
                           onTap: () {
                             final Id = profile?['id'];
                             if (Id == null) {
                               print('❌ Không có employerID, không thể mở CompanyJobs');
                               return;
                             }
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => EditProfilePage(profileId: Id.toString()),
                               ),
                             );

                           },
                           child: Row(
                             children: const [
                               Text("Thêm thông tin",
                                   style: TextStyle(
                                       fontSize: 16,
                                       color: Colors.blue,
                                       fontWeight: FontWeight.w500)),
                               SizedBox(width: 4),
                               Icon(Icons.arrow_forward_ios,
                                   size: 14, color: Colors.blue),
                             ],
                           ),
                         ),

                       ],
                    ),
                  ],
                ),
              ),

              // --- Hoàn tất thông tin cá nhân ---
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE1BEE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hoàn tất thông tin cá nhân",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C))),
                    SizedBox(height: 6),
                    Text("Hoàn thành thông tin cá nhân giúp bạn tiếp cận đến với nhà tuyển dụng và tìm được công việc phù hợp .",
                        style: TextStyle(color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tiêu chí tìm việc  ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Jobcriteriapage(),
                              ),
                            );

                          },
                          child:Row(
                            children: const [
                              Text("Cập nhật",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.blue),
                            ],
                          ) ,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mục tiêu nghề nghiệp",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          profile?['careerObjective'] ?? "",
                          maxLines: 3, // giới hạn số dòng
                          overflow: TextOverflow.ellipsis, // nếu dài quá sẽ có dấu "..."
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),

                        SizedBox(height: 20),
                        Text("Mức lương mong muốn",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          profile?['desiredSalary'] ?? "",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),

                        SizedBox(height: 20),
                        Text("Công việc mong muốn ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          profile?['userDesiredJob'] ?? "",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    )
                  ],
                ),

              ),
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Kinh nghiệm làm việc ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Experiencejob(),
                              ),
                            );

                          },
                          child:Row(
                            children: const [
                              Text("Thêm",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.blue),
                            ],
                          ) ,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Kinh nghiệm : ",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['experience'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Số năm kinh nghiệm  : ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['experienceYear'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Vị trí hiện tại : ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['userPosition'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                )

              ),
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child :Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Trình độ học vấn  ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Educationjob(),));

                          },
                          child:Row(
                            children: const [
                              Text("Thêm",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.blue),
                            ],
                          ) ,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Trường đại học: ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['education'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Năm tốt nghiệp  : ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['educationYear'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),

              ),

              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Kỹ năng ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Skilljob(),));

                          },
                          child:Row(
                            children: const [
                              Text("Thêm",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.blue),
                            ],
                          ) ,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Tên chứng trỉ: ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['certificateName'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Năm cấp chứng trỉ  : ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['certificateYear'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Giải thưởng: ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['prizeDesc'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Năm cấp giải thưởng  : ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['prizeYear'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Ngôn ngữ: ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['language'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    Text("Kỹ nằng mềm  : ",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),),
                    Text(
                      profile?['softSkill'] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PreviewCVPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C1BC8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Xem trước CV", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              // Chuyển sang Trang chủ
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ), // Thay HomePage bằng trang chính của bạn
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Myjobpage()),
              );
            }
            else if (index == 2) {
              // Chuyển sang Cá nhân
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()), // Thay ProfilePage bằng trang cá nhân
              );
            }
          },
          selectedItemColor: Color(0xFF6A11CB),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: 'Việc của tôi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: 'Cá nhân',
            ),
          ],
        ),
      );
    }
  }

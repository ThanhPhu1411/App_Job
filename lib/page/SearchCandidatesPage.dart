import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/service/EmployerService.dart';
import '../service/searchjob.dart';
import '../page/search_page.dart';
import '../service/saved_job_service.dart';
import 'CandidateProfilePage.dart';
import 'JobDetailPage.dart';

class Searchcandidatespage extends StatefulWidget {
  final String jobId;

  const Searchcandidatespage({Key? key, required this.jobId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Searchcandidatespage();
}

class _Searchcandidatespage extends State<Searchcandidatespage> {
  final keywordController = TextEditingController();
  final locationController = TextEditingController();
  final experienceController = TextEditingController();
  final desiredSalaryController = TextEditingController();
  final educationController = TextEditingController();
  final experienceYearController = TextEditingController();
  final userDesiredJobController = TextEditingController();
  final skillController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final EmployerService _employerService = EmployerService();
  List<dynamic> datas = [];
  bool isLoading = false;

  Future<void> searchCandidate() async {
    setState(() => isLoading = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    try {
      final result = await _employerService.searchCandidates(
        keyword: keywordController.text,
        location: locationController.text,
        skill: skillController.text,
        salary: desiredSalaryController.text,
        education: educationController.text,
        experienceYear: experienceYearController.text,
        experience: experienceController.text,
        desiredJob: userDesiredJobController.text,
        jobId: widget.jobId,
      );
      setState(() {
        datas = result?['data'] ?? [];
      });
    } catch (e) {
      print("lỗi :$e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tìm kiếm ứng viên"), centerTitle: true),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    // --- Các TextField ---
                    TextField(
                      focusNode: _focusNode,
                      controller: keywordController,
                      decoration: InputDecoration(
                        labelText: "Từ khóa",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: "Địa điểm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: skillController,
                      decoration: InputDecoration(
                        labelText: "Kỹ năng",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: experienceController,
                      decoration: InputDecoration(
                        labelText: "Kinh nghiệm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: experienceYearController,
                      decoration: InputDecoration(
                        labelText: "Số năm kinh nghiệm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: educationController,
                      decoration: InputDecoration(
                        labelText: "Học vấn",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: desiredSalaryController,
                      decoration: InputDecoration(
                        labelText: "Mức lương mong muốn",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: userDesiredJobController,
                      decoration: InputDecoration(
                        labelText: "Công việc mong muốn",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: searchCandidate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF451DA1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                        child: Text(
                          "Tìm kiếm",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // --- List kết quả ---
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: ListView.builder(
                            itemCount: datas.length,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final job = datas[index];

                              Color statusColor;
                              switch (job['status']) {
                                case "approved":
                                  statusColor = Colors.green;
                                  break;
                                case "pending":
                                  statusColor = Colors.orange;
                                  break;
                                case "rejected":
                                  statusColor = Colors.red;
                                  break;
                                default:
                                  statusColor = Colors.grey;
                              }

                              String statusToVietnamese(String status) {
                                switch (status) {
                                  case "approved":
                                    return "Đã duyệt";
                                  case "pending":
                                    return "Đang chờ";
                                  case "rejected":
                                    return "Bị từ chối";
                                  default:
                                    return "Không xác định";
                                }
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Colors.black.withOpacity(0.05),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(8),
                                      child: Image.network(
                                        "https://10.0.2.2:7044/images/${job['userAvatar']}",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  job['userName'],
                                                  style: TextStyle(
                                                    fontSize: 20,
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
                                                  color: statusColor
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  statusToVietnamese(
                                                    job['status'],
                                                  ),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Text(
                                                "Công việc ứng tuyển :",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['jobTitle'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Công việc mong muốn :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['userDesiredJob'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Học vấn :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['education'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Kỹ năng :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['softSkill'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Ngôn ngữ :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['language'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Kinh nghiệm :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['experience'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Số năm kinh nghiệm :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['experienceYear'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Địa chỉ :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['userAddress'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Mức lương mong muốn :",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  job['desiredSalary'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                              onTap: () async{
                                                print('jobId = ${job['job_ID']}, id = ${job['id']}'); // in ra console
                                                if (job['job_ID'] != null && job['id'] != null) {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CandidateProfilePage(
                                                        jobId: job['job_ID'],
                                                        profileId: job['id'],
                                                      ),
                                                    ),
                                                  );

                                                  if (result == true) {
                                                    searchCandidate();
                                                  }
                                                  Navigator.pop(context);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Hồ sơ không hợp lệ")),
                                                  );
                                                }
                                              },
                                              child:Text("Xem hồ sơ",
                                                style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),)
                                          )

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

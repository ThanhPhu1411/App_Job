import 'package:flutter/material.dart';
import 'package:webtimvieclam/service/applied_job_service..dart';
import '../service/job_service.dart';
import 'package:intl/intl.dart';
import 'CompanyJobsPage.dart';
import '../service/applied_job_service..dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;
  const JobDetailPage({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final JobserVice _jobserVice = JobserVice();
  final ApplyJob _applyJob = ApplyJob();
  Map<String, dynamic>? jobDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJobDetail();
  }


  Future<void> loadJobDetail() async {
    try {
      final detail = await _jobserVice.getJobDetail(widget.jobId);
      setState(() {
        jobDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi load công việc: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết công việc')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final employer = jobDetail?['employer'];

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://10.0.2.2:7044/images/${employer['companyLogo']}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        employer['companyName'] ?? 'Không có tên công ty',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  jobDetail?['jobTitle'] ?? 'Không có tiêu đề',
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF451DA1)),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.attach_money,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(jobDetail?['salary'] ?? 'Không có lương',
                        style: const TextStyle(
                            fontSize: 18, color: Color(0xFF451DA1)
                        )),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(jobDetail?['locate'] ?? 'Không có địa điểm',
                        style: const TextStyle(fontSize: 18, color: Color(0xFF451DA1))),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                // --- Mô tả ---
                const Text("Mô tả công việc",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Text(jobDetail?['jobDescription'] ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 18, height: 1.4)),
                const SizedBox(height: 20),


                const Text("Yêu cầu công việc",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Text(jobDetail?["requirements"] ?? "Không có yêu cầu",
                    style: const TextStyle(fontSize: 18, height: 1.4)),
                const SizedBox(height: 20),


                const Text("Quyền lợi",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Text(jobDetail?["benefits"] ?? "Không có quyền lợi",
                    style: const TextStyle(fontSize: 18, height: 1.4)),
                const SizedBox(height: 20),


                const Text("Thông tin chung",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ngày đăng: ${jobDetail?['postedDate'] != null
                            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(jobDetail!['postedDate']))
                            : 'Không có'}",
                        style: const TextStyle(height: 2.0, fontSize: 18),
                      ),
                      Text("Hình thức: ${jobDetail?['jobType'] ?? 'Không có'}",
                          style: const TextStyle(height: 2.0, fontSize: 18)),
                      Text("Ngành nghề: ${jobDetail?['category'] ?? 'Không có'}",
                          style: const TextStyle(height: 2.0, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Công ty",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    GestureDetector(
                      onTap: () {
                        final Id = employer?['id'];
                        if (Id == null) {
                          print('❌ Không có employerID, không thể mở CompanyJobs');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompanyJobs(employerId: Id.toString()),
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          Text("Xem trang công ty",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.blue),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),


                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://10.0.2.2:7044/images/${employer['companyLogo']}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        employer['companyName'] ?? 'Không có tên công ty',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.purple, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Địa chỉ : ${employer['companyAddress'] ?? 'Không có địa chỉ'}",
                        style:
                        const TextStyle(fontSize: 18, height: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people,
                        color: Colors.purple, size: 18),
                    const SizedBox(width: 6),
                    Text(
                        "Quy mô: ${employer['companySize'] ?? 'Không có'} nhân viên",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 15),

                const Text("Giới thiệu công ty",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  employer['companyDescription'] ?? 'Không có mô tả công ty',
                  style: const TextStyle(fontSize: 18, height: 1.5),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A2DFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final result = await _applyJob.applyJob(jobDetail!['id'].toString());
                if(result!=null)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ứng tuyển thành công')),
                    );
                  }
                else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ứng tuyển không thành công')),
                    );
                  }

              },
              child: const Text(
                'Ứng tuyển ngay',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

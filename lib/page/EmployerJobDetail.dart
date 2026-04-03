import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webtimvieclam/service/EmployerJobService.dart';

import 'UpdateJob.dart';

class EmployerJobDetail extends StatefulWidget {
  final String jobId;
  const EmployerJobDetail({Key? key, required this.jobId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmployerJobDetail();
}

class _EmployerJobDetail extends State<EmployerJobDetail> {
  final EmployerJobService _service = EmployerJobService();
  Map<String, dynamic>? jobdetail;
  bool isLoading = true;

  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      final result = await _service.getJobDetail(widget.jobId);
      if (result != null) {
        setState(() {
          jobdetail = result;
        });
      }
    } catch (e) {
      print('Lỗi thông báo : $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
  Map<String, dynamic> getStatusInfo(String? status) {
    switch (status) {
      case "pending":
        return {"text": "Đang chờ", "color": Colors.orange};
      case "approved":
        return {"text": "Đã duyệt", "color": Colors.green};
      case "rejected":
        return {"text": "Từ chối", "color": Colors.red};
      default:
        return {"text": "Không xác định", "color": Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết công việc"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tiêu đề công việc
                Text(
                  jobdetail?['jobTitle'] ?? 'Khong co tieu de',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),

                /// Salary
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jobdetail?['salary'] ?? 'Không có lương',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF451DA1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                /// Location
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jobdetail?['locate'] ?? 'Không có địa điểm',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF451DA1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                /// Category
                Row(
                  children: [
                    Icon(Icons.business_center,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jobdetail!['category']?['name'] ??
                            'Không có ngành',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF451DA1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                /// Job Type
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jobdetail!['jobType']?['jobType_Name'] ??
                            'Không có loại',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF451DA1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                /// Deadline
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jobdetail?['applicationDeadline'] != null
                            ? DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(
                              jobdetail!['applicationDeadline']),
                        )
                            : 'Không có',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF451DA1)),
                      ),
                    ),
                  ],
                ),

                Divider(),
                Text("Mô tả công việc",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Text(jobdetail?['jobDescription'] ?? 'Không có mô tả',
                    style:
                    TextStyle(fontSize: 18, height: 1.4)),
                SizedBox(height: 20),

                Text("Yêu cầu công việc",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Text(jobdetail?["requirements"] ?? "Không có yêu cầu",
                    style:
                    TextStyle(fontSize: 18, height: 1.4)),
                SizedBox(height: 20),

                Text("Quyền lợi",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Text(jobdetail?["benefits"] ?? "Không có quyền lợi",
                    style:
                    TextStyle(fontSize: 18, height: 1.4)),
                SizedBox(height: 20),

                Text("Trạng thái",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                /// Status badge
                Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: getStatusInfo(jobdetail!['status'])['color']
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusInfo(jobdetail!['status'])['text'],
                    style: TextStyle(
                        color:
                        getStatusInfo(jobdetail!['status'])['color'],
                        fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C1BC8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>UpdateJob(jobId : jobdetail!['id']),),);
                    },

                    child: Text("Chỉnh sửa công việc",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

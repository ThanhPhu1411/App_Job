import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webtimvieclam/page/CandidateProfilePage.dart';
import 'package:webtimvieclam/service/EmployerJobService.dart';

import '../service/EmployerService.dart';
import 'SearchCandidatesPage.dart';

class JobApplication extends StatefulWidget {
  final String jobId;

  const JobApplication({Key? key, required this.jobId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _JobApplication();
}

class _JobApplication extends State<JobApplication> {
  final EmployerService _employerService = EmployerService();
  Map<String, dynamic> start = {};
  List<dynamic> jobs = [];
  bool isLoading = true;

  void initState() {
    super.initState();
    loadData("all");
  }

  Future<void> loadData(String filter) async {
    final jobData = await _employerService.getJobsApplcaitons(
      widget.jobId,
      filter,
    );

    if (jobData != null) {
      setState(() {
        jobs = jobData['jobs'];
        start = jobData['start'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Ứng viên ứng tuyển",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),


      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(horizontal: 12),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                )
              ],
            ),
            child: TextField(
              readOnly: true, // để người dùng không bấm nhập
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Searchcandidatespage(jobId: widget.jobId),
                  ),
                );
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                hintText: "Tìm kiếm ứng viên",
                contentPadding: EdgeInsets.symmetric(vertical: 12),

              ),
            ),
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TẤT CẢ
              Expanded(
                child: GestureDetector(
                  onTap: () => loadData("all"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text("Tất cả : "),
                        Text(
                          (start['total'] ?? 0).toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),

              // CHỜ DUYỆT
              Expanded(
                child: GestureDetector(
                  onTap: () => loadData("pending"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text("Chờ duyệt :"),
                        Text(
                          (start['pending'] ?? 0).toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),

              // ĐÃ DUYỆT
              Expanded(
                child: GestureDetector(
                  onTap: () => loadData("approved"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text("Đã duyệt : "),
                        Text(
                          (start['approved'] ?? 0).toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),

              // TỪ CHỐI
              Expanded(
                child: GestureDetector(
                  onTap: () => loadData("rejected"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text("Từ chối : "),
                        Text(
                          (start['rejected'] ?? 0).toString(),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14),
          Expanded(child: ListView.builder(
               itemCount: jobs.length,
                itemBuilder: (context,index){
                 final job = jobs[index];
                 Color statusColor;
                 switch(job['status']){
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
                   margin: const EdgeInsets.only(bottom: 16),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.white70,
                     borderRadius: BorderRadius.circular(16),
                     boxShadow: [
                       BoxShadow(
                         blurRadius: 8,
                         color: Colors.black.withOpacity(0.05),
                       ),
                     ],
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Expanded(child: Text(
                             job['userName'],
                             style: TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           ),
                           Container(
                             padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                             decoration: BoxDecoration(
                               color: statusColor.withOpacity(0.12),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Text(
                               statusToVietnamese(job['status']),
                               style: TextStyle(
                                   color: statusColor, fontWeight: FontWeight.bold),
                             ),
                           ),
                         ],
                       ),
                       SizedBox(height: 12),
                       Row(
                         children: [
                           Text("Công việc ứng tuyển : ",
                             style: TextStyle(fontSize: 16),
                           ),
                           SizedBox(width: 5),
                           Text(
                             job['jobTitle'],
                             style: TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 15,
                             ),
                           ),
                         ],
                       ),
                       SizedBox(height: 9),
                       Row(
                         children: [
                           Text("Ngày nộp",
                             style: TextStyle(fontSize: 16),
                           ),
                           SizedBox(width: 5),
                           Text(job['applyDate']!=null
                           ?DateFormat('dd/MM/yyyy').format(DateTime.parse(job['applyDate'],
                               ),
                               )
                               :"Khong co",
                             style: TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 15,
                             ),
                           )
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
                             // Nếu result trả về true nghĩa là đã cập nhật trạng thái
                             if (result == true) {
                               loadData("all"); // reload dữ liệu
                             }
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
                 );

          }))
        ],
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webtimvieclam/page/Mycompany.dart';
import 'package:webtimvieclam/service/EmployerJobService.dart';

import 'AddJob.dart';
import 'EmployerJobDetail.dart';
import 'JobApplicationsPage.dart';
import 'NotificationDetailPage.dart';

class EmployerIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmployerIndex();
}

class _EmployerIndex extends State<EmployerIndex> {
  final EmployerJobService _employerJobService = EmployerJobService();
  Map<String, dynamic> start = {};
  List<dynamic> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData("all");
  }

  Future<void> loadData(String filter) async {
    final jobData = await _employerJobService.getJobs(filter);
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
    // int approvedJobs = start['approved'] ?? 0;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.work, color: Colors.blue),
            ),
            SizedBox(width: 10),
            Text(
              "Công việc của tôi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            icon: Icon(Icons.notifications_none, size: 30),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => loadData("all"),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              (start['total'] ?? 0).toString(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Tổng công việc",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => loadData("exprired"),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      start['exprired'].toString() ??
                                          'Khong co',
                                      // tổng job
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Công việc hết hạn",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => loadData("approved"),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.lightGreenAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      start['approved'].toString() ??
                                          'Khong co',
                                      // tổng job
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Công việc được duyệt",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => loadData("pending"),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.yellowAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      start['pending'].toString() ?? 'Khong co',
                                      // tổng job
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Công việc đang chờ",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => loadData("rejected"),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      start['rejected'].toString() ??
                                          'Khong co',
                                      // tổng job
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Công việc bị từ chối",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      "Công việc đã đăng",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: ListView.builder(
                            itemCount: jobs.length,

                            itemBuilder: (context, index) {
                              final job = jobs[index];
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
                                        Expanded(
                                          child: Text(
                                            job['jobTitle'],
                                            style: TextStyle(
                                              fontSize: 18,
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
                                            color: statusColor.withOpacity(
                                              0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            statusToVietnamese(job['status']),
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
                                          "Ứng viên ứng tuyển :",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          job['count'].toString(),
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
                                        Text(
                                          "Hạn nộp :",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          job['applicationDeadline'] != null
                                              ? DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(
                                                    job['applicationDeadline'],
                                                  ),
                                                )
                                              : 'Không có',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EmployerJobDetail(
                                                          jobId: job['id'],
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Xem",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        JobApplication(
                                                          jobId: job['id'],
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Xem ứng viên",
                                                style: TextStyle(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(width: 10),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                bool?
                                                confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text("Xác nhận"),
                                                    content: Text(
                                                      'Bạn có chắc muốn xóa công việc này không?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(false),
                                                        child: Text("Hủy"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(true),
                                                        child: Text(
                                                          "Xóa",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  bool success =
                                                      await _employerJobService
                                                          .deleteJob(job['id']);
                                                  if (success) {
                                                    setState(() {
                                                      jobs.removeAt(index);
                                                    });
                                                    await loadData("all");
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Xóa công việc thành công!',
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Xóa công việc thất bại!',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              child: Text(
                                                "Xóa",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 8,
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        job['isExpired'] == true
                                            ? 'Công việc đã hết hạn'
                                            : 'Còn ${job['dayleft']} ngày để ứng tuyển',
                                        style: TextStyle(
                                          color: job['isExpired'] == true
                                              ? Colors.red
                                              : Colors.grey[700],
                                          fontWeight: job['isExpired'] == true
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),

                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmployerIndex()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyCompany()),
            );
          }
        },
        selectedItemColor: Color(0xFF6A11CB),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: "Cá nhân",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddJob()),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}

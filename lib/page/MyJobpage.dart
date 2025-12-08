import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/page/profile_page.dart';
import 'package:webtimvieclam/service/MyApplications_service.dart';
import '../page/NotificationDetailPage.dart';
import '../page/notification_page.dart';
import '../page/search_page.dart';
import '../service/job_service.dart';
import '../service/saved_job_service.dart';
import '../view/index.dart';
import 'JobDetailPage.dart';

class Myjobpage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Myjobpage();
}

// TODO: implement createState
class _Myjobpage extends State<Myjobpage> with SingleTickerProviderStateMixin {
  // final JobserVice _jobserVice = JobserVice();
  final SavedJobService _SavedJobService = SavedJobService();
  final MyApplications _myApplications = MyApplications();

  // List<dynamic> jobs = [];
  bool isLoading = true;
  Set<String> likedJobs = {};
  List<dynamic> savedJobs = [];
  List<dynamic> applications = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    // final jobData = await _jobserVice.getJobsAll();
    final data = await _myApplications.fetchMyApplications();
    final savedData = await _SavedJobService.getSavedJobsAll();
    // final blogData = await _jobserVice.fetchBlogPosts();
    if (savedData != null && savedData['savedJobs'] != null) {
      final savedList = savedData['savedJobs'] as List;
      setState(() {
        applications = data?['applications'] ?? [];
        savedJobs = savedList;
        // Lưu danh sách jobId đã lưu để hiển thị tim đỏ
        likedJobs = savedList.map<String>((j) => j['jobId'] as String).toSet();
        // Gán thêm saveJobId vào từng job trong danh sách jobs
        isLoading = false;
      });
    } else {
      savedJobs = [];
      likedJobs = {};
      isLoading = false;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Việc của tôi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Việc đã lưu"),
            Tab(text: "Việc đã ứng tuyển"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          savedJobsTab(),
          applicationTab(),
          // placeholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

  Widget applicationTab() {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (applications.isEmpty)
      return Center(child: Text("Bạn chưa ứng tuyển công việc nào"));
    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailPage(jobId: app['id']),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://10.0.2.2:7044/images/${app['companyLogo']}",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app['companyName'] ?? "Khong co ten cong viec",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        Text(
                          app['jobTitle'] ?? "Khong co ten cong viec",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                app['locate'] ?? 'Không có tiêu đề',
                                style: TextStyle(color: Colors.grey[800]),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                app['salary'] ?? 'Không có lương',
                                style: TextStyle(color: Colors.purple),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                app['isExpired'] == true
                                    ? "Công việc đã hết hạn"
                                    : "Còn ${app['dayleft']} ngày để ứng tuyển",
                                style: TextStyle(
                                  color: app['isExpired'] == true
                                      ? Colors.red
                                      : Colors.grey[700],
                                  fontWeight: app['isExpired'] == true
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(app['statusText'] ?? "Khong co trang thai"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget savedJobsTab() {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (savedJobs.isEmpty)
      return Center(child: Text("Bạn chưa lưu công việc nào"));
    return ListView.builder(
      itemCount: savedJobs.length,
      itemBuilder: (context, index) {
        final job = savedJobs[index];
        final isLiked = likedJobs.contains(job['jobId']);
        return Opacity(
          opacity: job['isExpired' ?? false] ? 0.5 : 1,
          child: InkWell(
            onTap: (job['isExpired'] ?? false )? null
                :() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailPage(jobId: job['jobId']),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://10.0.2.2:7044/images/${job['companyLogo']}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job['companyName'] ??
                                      "Khong co ten cong viec",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (isLiked) {
                                    print("Chuẩn bị gọi deleteSave...");
                                    print(' Job ID: ${job['jobId']}');
                                    print(
                                      'saveJobId hiện tại: ${job['saveJobId']}',
                                    );
                                    final delete =
                                        await _SavedJobService.deleteSave(
                                          job['saveJobId'],
                                        );
                                    if (delete != null) {
                                      setState(() {
                                        likedJobs.remove(job['jobId']);
                                        savedJobs.removeAt(index);
                                      });
                                    }
                                  }
                                },
                                icon: Icon(Icons.favorite, color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            job['jobTitle'] ?? 'Không có tiêu đề',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  job['locate'] ?? '',
                                  style: TextStyle(color: Colors.grey[800]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job['salary'] ?? 'Không có lương',
                                  style: TextStyle(color: Colors.purple),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job['isExpired'] == true
                                      ? 'Công việc đã hết hạn'
                                      : 'Còn ${job['dayleft']} ngày để ứng tuyển ',
                                  style: TextStyle(
                                    color: job['isExpired'] == true
                                        ? Colors.red
                                        : Colors.grey[700],
                                    fontWeight: job['isExpired'] == true
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/service/searchjob.dart';
import '../page/search_page.dart';
import '../service/saved_job_service.dart';
import 'JobDetailPage.dart';

class SearchJob extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchJobState();
  // TODO: implement createState
}

class _SearchJobState extends State<SearchJob> {
  final _keywordController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final searchjob _searchjob = searchjob();
  final SavedJobService _SavedJobService = SavedJobService();
  List<dynamic> jobs = [];
  bool isLoading = false;
  Set<String> likedJobs = {};
  List<dynamic> savedJobs = [];

  Future<void> searchJobs() async {
    setState(() => isLoading = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    try {
      final result = await _searchjob.fetchJobs(
        keyword: _keywordController.text,
        location: _locationController.text,
        category: _categoryController.text,
      );
      setState(() {
        jobs = result?['job'];
      });
      await loadData();
    } catch (e) {
      print("Lỗi :$e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // final jobData = await _jobserVice.getJobsAll();
    final savedData = await _SavedJobService.getSavedJobsAll();
    // final blogData = await _jobserVice.fetchBlogPosts();
    if (savedData != null && savedData['savedJobs'] != null) {
      final savedList = savedData['savedJobs'] as List;
      setState(() {
        savedJobs = savedList;
        // Lưu danh sách jobId đã lưu để hiển thị tim đỏ
        likedJobs = savedList.map<String>((j) => j['jobId'] as String).toSet();
        // Gán thêm saveJobId vào từng job trong danh sách jobs
        for (var job in jobs) {
          //savedList = danh sách job đã lưu từ server (có saveJobId).
          final matched = savedList.firstWhere(
            (s) => s['jobId'] == job['id'],
            orElse: () => null,
          );
          if (matched != null) {
            job['saveJobId'] = matched['saveJobId'];
          }
        }
      });
    } else {
      savedJobs = [];
      likedJobs = {};
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm việc làm '), centerTitle: true),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    TextField(
                      focusNode: _focusNode,
                      readOnly: false,
                      controller: _keywordController,
                      decoration: const InputDecoration(
                        hintText: 'Công việc muốn ứng tuyển',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Vị trí',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        hintText: 'Ngành nghề',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: searchJobs,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF451DA1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                        child: Text(
                          'Tìm kiếm',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: jobs.length,
                        //itemCount: jobs.length
                        // jobs là danh sách dữ liệu (ở đây là danh sách các công việc).
                        // jobs.length = số lượng phần tử trong danh sách.
                        // Flutter sẽ tạo từng item trong ListView dựa trên số lượng này.
                        itemBuilder: (context, index) {
                          //Là hàm tạo widget cho mỗi item trong danh sách.
                          // index → chỉ số hiện tại của item (0, 1, 2, …).
                          // Trong hàm này, bạn trả về widget để hiển thị mỗi công việc, ví dụ Card, ListTile, hoặc Container.
                          final job = jobs[index];
                          final isLiked = likedJobs.contains(job['id']);
                          return Opacity(
                            opacity: job['isExpired' ?? false] ? 0.5 : 1,
                            child: InkWell(
                              onTap: (job['isExpired'] ?? false) ? null:
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        JobDetailPage(jobId: job['id']),
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
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    job['companyName'] ??
                                                        "Khong co ten cong viec",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                  ),
                                                ),

                                                IconButton(
                                                  //setState(() { ... }) → thông báo Flutter rằng trạng thái của widget thay đổi, UI sẽ được vẽ lại.
                                                  // onPressed là bấm
                                                  onPressed: () async {
                                                    if (isLiked) {
                                                      print(
                                                        "Chuẩn bị gọi deleteSave...",
                                                      );
                                                      print(
                                                        ' Job ID: ${job['id']}',
                                                      );
                                                      print(
                                                        '💾 saveJobId hiện tại: ${job['saveJobId']}',
                                                      );
                                                      final delete =
                                                          await _SavedJobService.deleteSave(
                                                            job['saveJobId'],
                                                          );
                                                      if (delete != null) {
                                                        setState(() {
                                                          likedJobs.remove(
                                                            job['id'],
                                                          );
                                                          job['saveJobId'] =
                                                              null;
                                                        });
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Đã hủy lưu công việc",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      final saveJobId =
                                                          await _SavedJobService.saveJob(
                                                            job['id'],
                                                          );
                                                      print(
                                                        "Response saveJob: $saveJobId",
                                                      );
                                                      if (saveJobId != null) {
                                                        setState(() {
                                                          likedJobs.add(
                                                            job['id'],
                                                          );
                                                          job['saveJobId'] =
                                                              saveJobId['saveJobId'];
                                                        });
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Đã lưu công việc",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  icon: Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isLiked
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              job['jobTitle'] ??
                                                  'Không có tiêu đề',
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
                                                    job['locate'] ??
                                                        'Không có tiêu đề',
                                                    style: TextStyle(
                                                      color: Colors.grey[800],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    job['salary'] ??
                                                        'Không có lương',
                                                    style: TextStyle(
                                                      color: Colors.purple,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                        : 'Còn ${job['daysLeft']} ngày để ứng tuyển ',
                                                    style: TextStyle(
                                                      color:
                                                          job['isExpired'] ==
                                                              true
                                                          ? Colors.red
                                                          : Colors.grey[700],
                                                      fontWeight:
                                                          job['isExpired'] ==
                                                              true
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

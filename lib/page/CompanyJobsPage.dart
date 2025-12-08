import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../page/NotificationDetailPage.dart';
import '../page/notification_page.dart';
import '../page/search_page.dart';
import '../service/job_service.dart';
import '../service/saved_job_service.dart';
import '../view/index.dart';
import 'JobDetailPage.dart';
import '../service/company_job_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
class CompanyJobs extends StatefulWidget{
  final String employerId;
  const CompanyJobs ({Key? key, required this.employerId}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CompanyJobs ();

}
class _CompanyJobs extends State<CompanyJobs> with SingleTickerProviderStateMixin {
  final SavedJobService _SavedJobService = SavedJobService();
  final CompanyJobService _companyJobService = CompanyJobService();
  List<dynamic> jobs = [];
  Map<String, dynamic>? companyData;
  bool isLoading = true;
  Set<String> likedJobs = {};
  List<dynamic> savedJobs = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    try {
      final detail = await _companyJobService.fetchCompanyJobs(widget.employerId);
      setState(() {
        companyData = detail;
        //as List<dynamic>
        // Phần này là ép kiểu (type casting) — để Dart biết chắc đây là một danh sách (List) chứa dữ liệu kiểu bất kỳ (dynamic).
        //hiện danh sách các công việc
        jobs = (detail?['jobs'] ?? []) as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      print('Loi load cong viec : $e');
    }

    final saveData = await _SavedJobService.getSavedJobsAll();
    if (saveData != null && saveData['savedJobs'] != null) {
      final savedList = saveData['savedJobs'] as List;
      setState(() {
        savedJobs = savedList;
        likedJobs =
            savedList.map<String>((j) => j['jobId'] as String).toSet();
        for (var job in jobs) {
          final matched =
          savedList.firstWhere(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // 🟣 Header với ảnh nền
          SliverToBoxAdapter(
            child: Column(
              children: [
                //Stack là widget cho phép các phần tử chồng lên nhau theo thứ tự z-index
                Stack(
                  clipBehavior: Clip.none,//Cho phép phần tử con vẽ ra ngoài Stack
                  alignment: Alignment.center,
                  children: [
                    // Background
                    Image.asset(
                      'assets/company.jpg',
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 40, // khoảng cách từ trên xuống (điều chỉnh cho đẹp)
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () {
                          Navigator.pop(context);// qua lại trang trước
                        },
                      ),
                    ),
                    // Logo nổi trên background
                    Positioned(
                      // Kéo logo xuống khỏi cạnh dưới của ảnh
                      bottom: -45,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "https://10.0.2.2:7044/images/${companyData?['jobs']?[0]?['employerLogo'] ?? 'Chua%20co%20hinh'}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported,
                                    size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // 🏢 Tên công ty
                Text(
                  companyData?['jobs']?[0]?['employerName'] ??
                      'Chưa có tên công ty',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // 🏠 Thông tin cơ bản công ty
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.purple[50],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              companyData?['jobs']?[0]
                              ?['employerAddress'] ??
                                  'Chưa có địa chỉ',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.groups_2_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              companyData?['jobs']?[0]
                              ?['employerSize'] ??
                                  'Chưa có thông tin quy mô',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 📑 Tab
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: const [
                    Tab(text: 'Thông tin'),
                    Tab(text: 'Việc làm'),
                  ],
                ),

                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(),
                      _buildJobsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final job = companyData?['jobs']?[0];

    if (job == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Không có thông tin công ty.'),
      );
    }

    final description = job['employerDescription'] ?? 'Không có mô tả công ty.';
    final address = job['employerAddress'] ?? 'Không có địa chỉ.';
    final latitude = job['employerLatitude'];
    final longitude = job['employerLongitude'];
    final email = job['employerEmail'] ?? 'Không có mô tả công ty.';

    Future<void> _openMap() async {
      if (latitude == null || longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có vị trí để chỉ đường')),
        );
        return;
      }
      final zoomLevel = 30;
      // Link mở trên trình duyệt, không cần đăng nhập
      final googleUrl = Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');

      try {
        await launchUrl(
          googleUrl,
          mode: LaunchMode.externalApplication, // luôn mở trên trình duyệt
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở bản đồ.')),
        );
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Giới thiệu về chúng tôi : ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // 🏢 Mô tả công ty
            Text(
              description,
              style: const TextStyle(fontSize: 18, height: 1.4),
            ),
            const SizedBox(height: 20),
            // 📍 Địa chỉ
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔘 Nút chỉ đường
            if (latitude != null && longitude != null)
              ElevatedButton.icon(
                onPressed: _openMap,
                icon: const Icon(Icons.directions),
                label: const Text('Chỉ đường đến đây'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 🗺️ Bản đồ vị trí công ty
            if (latitude != null && longitude != null)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.webtimvieclam',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              const Text('Không có tọa độ để hiển thị bản đồ.'),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsTab() {
   if(isLoading) {
     return Center(
         child: CircularProgressIndicator());
   }
     if(jobs.isEmpty)
       {
         return Center(child: Text("Chua co cong viec nao"));
       }
     return ListView.builder(
          itemCount: jobs.length,
         itemBuilder:(context, index){
            final job = jobs[index];
            final isLike = likedJobs.contains(job['id']);
            return InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailPage(jobId: job['id']),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "https://10.0.2.2:7044/images/${job['employerLogo']}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job['jobTitle'] ?? 'Không có tiêu đề',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            IconButton(
                              //setState(() { ... }) → thông báo Flutter rằng trạng thái của widget thay đổi, UI sẽ được vẽ lại.
                              // onPressed là bấm
                              onPressed: () async {
                                if (isLike) {
                                  print("Chuẩn bị gọi deleteSave...");
                                  print(' Job ID: ${job['id']}');
                                  print('💾 saveJobId hiện tại: ${job['saveJobId']}');
                                  final delete = await _SavedJobService.deleteSave(job['saveJobId']);
                                  if (delete!=null) {
                                    setState(() {
                                      likedJobs.remove(job['id']);
                                      job['saveJobId'] = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Đã hủy lưu công việc")),
                                    );
                                  }
                                } else {
                                  final saveJobId = await _SavedJobService.saveJob(job['id']);
                                  print("Response saveJob: $saveJobId");
                                  if (saveJobId != null) {
                                    setState(() {
                                      likedJobs.add(job['id']);
                                      job['saveJobId'] = saveJobId['saveJobId'];
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Đã lưu công việc")),
                                    );
                                  }
                                }
                              },
                              icon: Icon(isLike ? Icons.favorite : Icons.favorite_border,
                                color: isLike ? Colors.red : Colors.grey,),
                            ),
                          ],
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
                                style: TextStyle(color: Colors.grey[700]),
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
                                style: TextStyle(color: Colors.grey[700]),
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
            );
     }
     );
   }
  }


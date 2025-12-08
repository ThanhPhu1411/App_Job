import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../service/notification_service.dart';
import '../page/NotificationDetailPage.dart';
class NotificationDetail extends StatefulWidget{
  final int notifiId;
  const NotificationDetail({Key? key, required this.notifiId}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _NotificationDetail();
}

class _NotificationDetail  extends State<NotificationDetail> {
  final NotificationService _service = NotificationService();
  Map<String , dynamic > ? notification ;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadDetail();
  }
  Future<void> loadDetail() async{
    try{
      final result = await _service.getDetail(widget.notifiId);
      if(result != null && result['notification'] != null){
        setState(() {
          notification = result['notification'];
        });
      }
    }catch(e){
      print('Lỗi thông báo : $e');

    }finally{
      setState(() => isLoading = false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết thông báo'),
        centerTitle: true,
      ),
      body: SafeArea(child: isLoading
      ?const Center(child: CircularProgressIndicator())
      :Padding(padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification?['title'] ?? '(Không có tiêu đề)',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              (notification?['message'] ?? 'Không có tiêu đề')
                  .toString()
                  .replaceAll(RegExp(r'<br\s*/?>'), '\n') // đổi <br> thành xuống dòng
                  .replaceAll(RegExp(r'<[^>]*>'), ''),   // xoá các thẻ khác
            ),
            const SizedBox(height: 10),
            Text("Gửi lúc ${notification?['sentDate']??'Không có tiêu đề'})",
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),)),

    );

  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../service/notification_service.dart';
import '../page/notification_page.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _service = NotificationService();
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final result = await _service.fetchAll(page: 1, pageSize: 20);
      if (result != null && result['notifications'] != null) {
        setState(() {
          notifications = result['notifications'];
        });
      }
    } catch (e) {
      print('Lỗi load thông báo: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsRead(int id) async {
    await _service.getDetail(id);
    setState(() {
      //Tìm vị trí (index) của thông báo trong danh sách notifications có
      // id trùng với id được truyền vào.
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) notifications[index]['isRead'] = true;
    });
  }
  //
  // String formatDate(String dateStr) {
  //   try {
  //     final date = DateTime.parse(dateStr);
  //     return DateFormat('dd/MM/yyyy HH:mm').format(date);
  //   } catch (e) {
  //     return dateStr;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
        centerTitle: true,
      ),
      body: SafeArea(child: isLoading
      ?const Center(child: CircularProgressIndicator())
          :Padding(padding: const EdgeInsets.symmetric(horizontal:5 , vertical: 10),
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index){
                  final n = notifications[index];
                  return Card(
                    color: n['isRead'] ? Colors.grey[200] : Colors.white,
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child:  ListTile(
                  title:Text(n['title'],
                  style: TextStyle(
                  fontWeight: n['isRead'] ? FontWeight.normal : FontWeight.bold,
                  ),
                  ),
                  subtitle:
                  Text(
                  n['message'].toString().replaceAll(RegExp(r'<[^>]*>'), ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  ),
                  trailing:  n['isRead']
                  ? const Icon(Icons.done, color: Colors.grey)
                      : const Icon(Icons.mark_email_unread, color: Colors.blue),
                      onTap: ()async{
                        await markAsRead( n['id']);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationDetail(notifiId:n['id']),),);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã đánh dấu là đã đọc')),
                        );
                      },
                  ),
                  );
                }))
        ],
      ),)
      ),
    );
  }
}

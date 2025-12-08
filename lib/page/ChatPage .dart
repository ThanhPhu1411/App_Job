import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../service/ChatBox_servicde.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ChatBox _chatBox = ChatBox();
  final List<Map<String, dynamic>> _messages = [];
  bool isLoading = false;

  // 👇 Thêm biến animation cho câu chào
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();

    // Animation từ 0 → 1 → 0 (fade in rồi fade out)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _fadeController.forward();

    // Sau 3 giây thì ẩn câu giới thiệu
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showIntro = false;
      });
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _controller.clear();
      isLoading = true;
    });

    final historyToSend = _messages.sublist(0, _messages.length - 1);

    try {
      final response = await _chatBox.askJob(text, historyToSend);
      final reply = response?['message'] ?? 'Không có phản hồi';

      setState(() {
        _messages.add({'text': reply, 'isUser': false});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Lỗi: $e', 'isUser': false});
        isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['isUser'] as bool;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: isUser
            ? Text(
          msg['text'],
          style: const TextStyle(color: Colors.white),
        )
            : MarkdownBody(
          data: msg['text'],
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 16, color: Colors.black87),
            strong: const TextStyle(fontWeight: FontWeight.bold),
            code: TextStyle(
              backgroundColor: Colors.grey[200],
              fontFamily: 'monospace',
              color: Colors.red[700],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Trợ lý công việc"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Phần chính: Chat
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(_messages[index]);
                  },
                ),
              ),
              if (isLoading) const LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Nhập câu hỏi...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onSubmitted: isLoading ? null : (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: isLoading ? null : _sendMessage,
                      child: const Icon(Icons.send),
                      mini: true,
                    )
                  ],
                ),
              )
            ],
          ),

          // 👇 Câu giới thiệu xuất hiện ở giữa, fade in rồi biến mất
          if (_showIntro)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 3))
                    ],
                  ),
                  child: const Text(
                    "💬 Xin chào! Tôi là Trợ lý công việc của nhóm Unemployment"
                        ".\nTôi có thể giúp bạn viết CV, tìm việc, hay trả lời câu hỏi nghề nghiệp!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

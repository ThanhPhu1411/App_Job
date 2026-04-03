import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/login_page.dart'; // import trang login

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Hiệu ứng fade in logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Sau 3 giây thì chuyển sang trang Login
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hiện ngay lập tức
            Image.asset('assets/job3.jpg', height: 120),

            const SizedBox(height: 20),

            // Phần chữ fade-in từ từ
            FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: const [
                  Text(
                    "Tìm việc làm dễ dàng hơn",
                    style: TextStyle(
                      color: Color(0xFF451DA1),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ứng tuyển một chạm - Mọi lúc, mọi nơi",
                    style: TextStyle(
                      color: Color(0xFF451DA1),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF451DA1)),
          ],
        ),
      ),
    );
  }
}

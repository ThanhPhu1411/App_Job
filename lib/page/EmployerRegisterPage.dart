import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/login_page.dart';
import 'package:webtimvieclam/page/EmployerLoginPage.dart';
import 'package:webtimvieclam/service/AuthService.dart';
import 'package:webtimvieclam/service/EmployerAutService.dart';


class EmployerRegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmployerRegisterPage();
}

class _EmployerRegisterPage extends State<EmployerRegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthEmployerService _service = AuthEmployerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/job3.jpg', height: 100),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 6),
                child: Text(
                  "Tạo tài khoản mới",
                  style: TextStyle(fontSize: 24, color: Color(0xFF451DA1)),
                ),
              ),
              const Text(
                "Đăng ký nhanh với nhà tuyển dụng ",
                style: TextStyle(fontSize: 18, color: Color(0xFF451DA1)),
              ),

              // 🔹 Email
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Nhập email của bạn",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffCED0D2)),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    suffixIcon: IconButton(
                      onPressed: () => _emailController.clear(),
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),

              // 🔹 Mật khẩu
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    hintText: "Nhập mật khẩu",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffCED0D2)),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => _passwordController.clear(),
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),

              // 🔹 Xác nhận mật khẩu
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  hintText: "Nhập lại mật khẩu",
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffCED0D2)),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => _confirmPasswordController.clear(),
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),

              // 🔹 Nút đăng ký
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: () async {
                        final userName = _usernameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final confirmPassword = _confirmPasswordController.text.trim();
                        // ✅ Kiểm tra mật khẩu khớp không
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mật khẩu không khớp!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final result = await _service.register(email, password, userName);
                        if(result !=null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'])),
                          );
                          print(
                              "UserId: $userName, Email: ${result['email']}, Password : $password,");
                          // 🔹 Nếu đăng ký thành công, chuyển sang trang login
                          if (result['message'] == "Đăng ký thành công") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginEmployerPage()),
                            );
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar (content : Text("Đăng ký thất bại !")),
                          );
                        }

                        // TODO: gọi API đăng ký
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đăng ký thành công!"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF451DA1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔹 Quay lại đăng nhập
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: RichText(
                  text: TextSpan(
                    text: "Đã có tài khoản? ",
                    style:
                    const TextStyle(color: Color(0xff606470), fontSize: 16),
                    children: [
                      TextSpan(
                        text: "Đăng nhập",
                        style: const TextStyle(
                            color: Color(0xff3277D8), fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginEmployerPage()),);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 40),
                child:GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()),);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh,
                        color: Color(0xFF3277D8),
                        size: 30,
                      ),
                      Text("Chuyển sang ứng viên",
                        style:TextStyle(
                            color: Color(0xFF3277D8),
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                        ),)
                    ],
                  ),
                ),)
            ],
          ),
        ),
      ),
    );
  }
}

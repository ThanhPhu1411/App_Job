import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webtimvieclam/login_page.dart';
import 'package:webtimvieclam/page/AddCompany.dart';
import 'package:webtimvieclam/page/EmployerIndex.dart';
import 'package:webtimvieclam/register_page.dart';
import 'package:webtimvieclam/service/EmployerAutService.dart';
import 'package:webtimvieclam/service/EmployerService.dart';
import 'package:webtimvieclam/view/index.dart';
class LoginEmployerPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LoginEmployerPage();

}

class _LoginEmployerPage extends  State <LoginEmployerPage>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthEmployerService _service = AuthEmployerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( //  tránh bị che bởi thanh trạng thái
        child: SingleChildScrollView( //  cho phép cuộn nếu nội dung dài
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 80),
                Image.asset('assets/job3.jpg', height: 100),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 6),
                  child: Text(
                    "Nhanh hơn, dễ dàng hơn",
                    style: TextStyle(fontSize: 22, color: Color(0xFF451DA1)),
                  ),
                ),
                const Text(
                  "Đăng nhập nhanh với nhà tuyển dụng",
                  style: TextStyle(fontSize: 20, color: Color(0xFF451DA1)),
                ),

                // 🔹 Ô nhập Email
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Nhập email của bạn",
                      border: const OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Color(0xffCED0D2), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _emailController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),

                // 🔹 Ô nhập Mật khẩu
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    hintText: "Nhập mật khẩu của bạn",
                    border: const OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xffCED0D2), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _passwordController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),

                // 🔹 Quên mật khẩu
                Container(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Quên mật khẩu ?",
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xff606470)),
                    ),
                  ),
                ),

                // 🔹 Nút đăng nhập
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click, // 🖱️ hiện ngón trỏ khi hover
                      child: ElevatedButton(
                        onPressed: () async {
                          // TODO: xử lý khi nhấn nút đăng nhập
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          if(email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(
                                  "Vui lòng nhập email và mật khẩu")),
                            );
                            return;
                          }
                          final result = await _service.login(email, password);
                          if(result!=null) {
                            final userId = result['userId'];
                            final userName = result['userName'];
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Đăng nhập thành công!")),
                            );
                            print("UserId: $userId, Email: ${result['email']}");
                            final company = await _service.getCompany(userId);
                            if(company!=null)
                              {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployerIndex()),);
                              }
                            else{
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddCompanyPage()),);
                            }

                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Email hoặc mật khẩu không đúng")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF451DA1),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                // 🔹 Đăng ký ngay
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: RichText(
                    text: TextSpan(
                      text: "Bạn chưa có tài khoản? ",
                      style: const TextStyle(
                          color: Color(0xff606470), fontSize: 16),
                      children: [
                        TextSpan(
                          text: "Đăng ký ngay",
                          style: const TextStyle(
                              color: Color(0xff3277D8), fontSize: 16),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: điều hướng sang trang đăng ký
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RegisterPage()),);
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


                // 🔹 Thêm khoảng cách để tránh bị che khi bàn phím mở
         

              ],

            ),
          ),
        ),
      ),
    );
  }
}
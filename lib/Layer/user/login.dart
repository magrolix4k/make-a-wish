import 'dart:convert';

import 'package:easy_actions/easy_actions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Presentation/main.dart';
import '../user/register.dart';
import '../utils/colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    try {
      String url = 'https://makeawish.comsciproject.net/scifoxz/db_login.php';
      var res = await http.post(Uri.parse(url), body: {
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
      });
      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);
        if (resBody['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('username', _usernameController.text.trim());
          Get.to(MyHomePage());
        } else {
          final snackBar = SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar =
            SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (errorMsg) {
      print("Error :: " + errorMsg.toString());
    }
  }

  void _navigateToSignup() {
    Get.to(SignupPage());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mainBlackColor, AppColors.mainColor],
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MakeAwish",
                style: TextStyle(
                  color: AppColors.bBgColor,
                  fontFamily: 'IrishGrover',
                  fontWeight: FontWeight.w400,
                  fontSize: screenWidth * 0.1,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Card(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: 'IrishGrover',
                          fontWeight: FontWeight.w400,
                          fontSize: screenWidth * 0.1,
                        ),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'ชื่อผู้ใช้',
                          border: UnderlineInputBorder(),
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกชื่อผู้ใช้';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          border: UnderlineInputBorder(),
                          filled: true,
                          fillColor: Colors.black12,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกรหัสผ่าน';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      EasyElevatedButton(
                        label: 'เข้าสู่ระบบ',
                        labelStyle: TextStyle(
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w100,
                          fontSize: screenWidth * 0.04,
                        ),
                        borderRadius: screenWidth * 0.1,
                        isRounded: true,
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.06,
                        color: AppColors.btnColor,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _handleLogin();
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Divider(color: AppColors.blackColor),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'ยังไม่มีบัญชี ? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            TextSpan(
                              text: 'สมัครสมาชิก',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.04,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _navigateToSignup,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

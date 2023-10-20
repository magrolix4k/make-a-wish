import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api_connection.dart';
import '../user/login.dart';
import '../utils/colors.dart';
import '../widgets/ReuseableText.dart';
import '../Domain/EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ImageProvider<Object>? profileImage = AssetImage('assets/image/DPP.png');
  String? username;
  String? s_username;
  String? id_username;
  String? s_birthday;
  String? imageBase64;
  String? rawBirthday;
  MemoryImage? _profileImage;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    if (savedUsername != null) {
      setState(() {
        username = savedUsername;
      });
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    final response = await http.post(
      Uri.parse(API.hostUserdata),
      body: {
        'username': username!,
      },
    );
    if (response.statusCode == 200) {
      final parsedData = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        id_username = parsedData['user_id'];
        s_username = parsedData['username'];
        rawBirthday = parsedData['birthday'];
        if (rawBirthday != null) {
          DateTime parsedDate = DateTime.parse(rawBirthday!);
          s_birthday = DateFormat('dd MMM yyyy').format(parsedDate);
        }
        imageBase64 = parsedData['image'];
        if (imageBase64 != null) {
          _profileImage = MemoryImage(base64Decode(imageBase64!));
        }
        prefs.setString('s_username', s_username!);
        prefs.setString('s_birthday', s_birthday!);
        prefs.setString('imageBase64', imageBase64!);
        prefs.setString('user_id', id_username!);
      });
    } else {
      print('Failed to fetch user data');
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Get.to(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Icon(Icons.keyboard_arrow_left,
                                color: Colors.white),
                            SizedBox(width: screenWidth * 0.30),
                            ReusableText(
                              text: 'โปรไฟล์',
                              color: AppColors.mainColor,
                              size: screenWidth * 0.06,
                              alignment: Alignment.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _handleLogout(context),
                            child: Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              child: Icon(FontAwesomeIcons.signOutAlt,
                                  color: Colors.white),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                                color: AppColors.mainColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.1),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundImage: _profileImage,
                    child: imageBase64 != null
                        ? null
                        : const CircularProgressIndicator(),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    '$id_username',
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'ชื่อผู้ใช้: $s_username',
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    'วันเกิด: $s_birthday',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(EditProfilePage(
                          currentUsername: s_username,
                          currentBirthday: rawBirthday,
                          currentImg: imageBase64));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      minimumSize: Size(screenWidth * 0.4, screenWidth * 0.12),
                    ),
                    child: Text(
                      'แก้ไขข้อมูล',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
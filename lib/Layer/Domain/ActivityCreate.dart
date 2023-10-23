import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../widgets/colors.dart';
import '../widgets/ReuseableText.dart';

class CreateActivity extends StatefulWidget {
  late final String userId;
  late final String placeId;

  CreateActivity({required this.userId, required this.placeId});

  @override
  _CreateActivityState createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivity> {
  TextEditingController _TextController = TextEditingController();

  Future<void> addActivity(String userId, String placeId, String activityDetail) async {
    DateTime currentTime = DateTime.now();
    String timestamp = currentTime.toIso8601String();

    final url = 'https://makeawish.comsciproject.net/scifoxz/_addActivity.php';

    try {
      final response = await http.post(Uri.parse(url), body: {
        'user_id': userId,
        'place_id': placeId,
        'activity_detail': activityDetail,
        'activity_timestamp': timestamp,
      });

      print('user_id:' +userId);
      print('place_id: ' +placeId);
      print('activity_detail:'+activityDetail);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Future.delayed(Duration(milliseconds: 1000), () {
            Navigator.pop(context);
          });
          print('เพิ่มกิจกรรมสำเร็จ');
        } else {
          print('เกิดข้อผิดพลาดในการเพิ่มกิจกรรม');
        }
      } else {
        print('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการส่งคำขอหรือตอบสนอง: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      child:
                      Icon(Icons.keyboard_arrow_left, color: Colors.white),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        color: AppColors.mainColor,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      ReusableText(
                        text: 'เพิ่มกิจกรรมของคุณ',
                        color: AppColors.mainColor,
                        size: screenWidth * 0.05,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      addActivity(widget.userId, widget.placeId, _TextController.text);
                    },
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      child:
                      Icon(Icons.check, color: Colors.white),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        color: AppColors.mainColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildInputContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _TextController,
          maxLines: 5,
          style: TextStyle(fontSize: 16.0, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'คุณได้บนอะไรไว้หรือไม่?',
            hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(20.0),
          ),
        ),
      ),
    );
  }
}
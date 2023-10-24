import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../Data/ActivityEdit.dart';
import '../widgets/ReuseableText.dart';
import '../widgets/colors.dart';

class ActivityDetailsPage extends StatefulWidget {
  final Map<String, dynamic> ActivityData;
  const ActivityDetailsPage({super.key, required this.ActivityData});

  @override
  _ActivityDetailsPageState createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double largeScreenWidth = 600;
    Uint8List imageBytes = base64Decode(widget.ActivityData['place_image']);
    print(widget.ActivityData['activity_status']);

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
                        text: widget.ActivityData['place_name'],
                        color: AppColors.mainColor,
                        size: screenWidth * 0.06,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(EditActivity(ActivityData: widget.ActivityData,));
                    },
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      child: Icon(FontAwesomeIcons.pencil,
                          color: Colors.white),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        color: AppColors.mainColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Container(
                width: screenWidth > largeScreenWidth
                    ? largeScreenWidth
                    : screenWidth * 0.8,
                height: screenWidth > largeScreenWidth
                    ? largeScreenWidth
                    : screenWidth * 0.8,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  margin:
                  EdgeInsets.only(right: 16, left: 16, bottom: 10, top: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_chart, color: AppColors.mainColor),
                            SizedBox(width: 8),
                            Text(': '+ widget.ActivityData['activity_detail']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin:
                  EdgeInsets.only(right: 16, left: 16, bottom: 10, top: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('สถานะ : '),
                            SizedBox(width: 8),
                            Text(widget.ActivityData['activity_status'] == '0' ? 'ยังไม่แก้บน' : 'แก้บนแล้ว'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
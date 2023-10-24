
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Domain/ActivityDetailsPage.dart';
import '../widgets/colors.dart';
import '../widgets/ReuseableText.dart';

class EditActivity extends StatefulWidget {
  final Map<String, dynamic> ActivityData;
  const EditActivity({super.key, required this.ActivityData});

  @override
  _EditActivityState createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  late String editActivityDetail = widget.ActivityData['activity_detail'];
  List<Map<String, dynamic>> activityStatusOptions = [
    {'value': 0, 'label': 'ยังไม่แก้บน'},
    {'value': 1, 'label': 'แก้บนแล้ว'},
  ];

  int selectedActivityStatus = 0;

  @override
  void initState() {
    super.initState();
    int? activityStatus = int.tryParse(widget.ActivityData['activity_status']);
    if (activityStatus != null) {
      selectedActivityStatus = activityStatus;
    }
  }
  Future<void> updateActivity() async {
    final url = Uri.parse('https://makeawish.comsciproject.net/scifoxz/_editActivity.php');

    final response = await http.post(url, body: {
      'activity_id': widget.ActivityData['activity_id'].toString(),
      'activity_detail': editActivityDetail,
      'activity_status': selectedActivityStatus.toString(),
    });
    if (response.statusCode == 200) {
      print('Activity updated successfully');
      Future.delayed(const Duration(milliseconds: 1000), () {
        Get.to(ActivityDetailsPage(ActivityData: widget.ActivityData,));
      });
    } else {
      print('Failed to update activity');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
                        size: screenWidth * 0.04,
                        alignment: Alignment.center,
                      ),
                      Row(
                        children: [
                          reusableText(
                              text: widget.ActivityData['activity_id'],
                              color: Colors.black54)
                        ],
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      updateActivity();
                      Navigator.pop(context);
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
                        TextField(
                          controller: TextEditingController(text: editActivityDetail),
                          onChanged: (value) {
                            setState(() {
                              editActivityDetail = value;
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        DropdownButtonFormField<int>(
                          value: selectedActivityStatus,
                          items: activityStatusOptions.map((option) {
                            return DropdownMenuItem<int>(
                              value: option['value'],
                              child: Text(option['label']),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                selectedActivityStatus = value;
                              });
                            }
                          },
                        )
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
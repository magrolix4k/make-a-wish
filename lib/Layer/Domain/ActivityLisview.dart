import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../widgets/ReuseableText.dart';
import 'ActivityDetailsPage.dart';

class ActivityListview extends StatefulWidget {
  const ActivityListview({super.key});

  @override
  State<ActivityListview> createState() => _ActivityListviewState();
}

class _ActivityListviewState extends State<ActivityListview> {
  List<dynamic> dataFromDatabase = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }
  Future<void> deleteActivity(int activityId) async {
    try {
      final url = Uri.parse('https://makeawish.comsciproject.net/scifoxz/_deleteActivity.php');
      final response = await http.post(url, body: {'activity_id': activityId.toString()});

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        if (responseJson['success']) {
          fetchDataFromDatabase();
          print('ลบสำเร็จ: ${response.statusCode}');
        } else {

        }
      } else {
        print('ไม่สามารถลบข้อมูลได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดขณะลบข้อมูล: $error');
    }
  }

  Future<void> fetchDataFromDatabase() async {
    try {
      final url = Uri.parse('https://makeawish.comsciproject.net/scifoxz/ActivityData.php');
      final response = await http.post(url ,body: {});
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          dataFromDatabase = responseData;
        });
      } else {
        print('ไม่สามารถดึงข้อมูลได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดขณะดึงข้อมูล: $error');
    }
  }

  void _navigateToActivityDetails(
      BuildContext context,
      Map<String, dynamic> ActivityData,
      ) {
    Get.to(ActivityDetailsPage(ActivityData: ActivityData));
  }

  Widget buildActivityItem(Map<String, dynamic> item, double screenWidth) {
    final Uint8List imageBytes = base64Decode(item['place_image']);
    final double imageSize = screenWidth * 0.25;

    return GestureDetector(
      onTap: () {
        _navigateToActivityDetails(context, item);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(imageSize * 0.5),
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 7.0,
                ),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  try {
                    return Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    );
                  } catch (e) {
                    return Text("Image loading error");
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                height: imageSize,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableText(
                          text: item['place_name'],
                          size: screenWidth * 0.05,
                          alignment: Alignment.center
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ReusableText(
                        text: item['activity_datetime'],
                        size: screenWidth * 0.04,
                        alignment: Alignment.center,
                      ),
                      SizedBox(height: screenWidth * 0.02),

                      Wrap(
                        children: [
                          SizedBox(width: 5.0),
                          Container(
                            width: 15.0,
                            height: 15.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item['activity_status'] == '1' ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )

                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(item['activity_id']);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dataFromDatabase.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> item = dataFromDatabase[index];
            return buildActivityItem(item, screenWidth);
          },
        ),
      ],
    );
  }
  void _showDeleteConfirmationDialog(String activityId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจหรือไม่ที่ต้องการลบความคิดเห็นนี้?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                // Send a DELETE request to delete the item
                deleteActivity(int.parse(activityId));
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ลบ'),
            ),
          ],
        );
      },
    );
  }
}
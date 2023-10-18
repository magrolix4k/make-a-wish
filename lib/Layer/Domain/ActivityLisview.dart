import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/ReuseableText.dart';

class ActivityListview extends StatefulWidget {
  const ActivityListview({super.key});

  @override
  State<ActivityListview> createState() => _ActivityListviewState();
}

class _ActivityListviewState extends State<ActivityListview> {
  List<dynamic> dataFromDatabase = [];
  List<dynamic> dataFromPreferences = [];

  Future<void> fetchDataFromDatabase() async {
    try {
      final url = Uri.parse('https://makeawish.comsciproject.net/scifoxz/ActivityData.php');
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          dataFromDatabase = responseData;
        });} else {
        print('ไม่สามารถดึงข้อมูลได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดขณะดึงข้อมูล: $error');
    }
  }
  Widget buildActivityItem(Map<String, dynamic> item, double screenWidth) {
    final Uint8List imageBytes = base64Decode(item['place_image']);
    final double imageSize = screenWidth * 0.25;

    return GestureDetector(
      onTap: () {
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
                          alignment: Alignment.center),
                      SizedBox(height: screenWidth * 0.02),
                      ReusableText(
                          text: item['place_nameHoly'],
                          size: screenWidth * 0.04,
                          alignment: Alignment.center),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableText(
                            text: 'จ.' + item['place_province'],
                            size: screenWidth * 0.035,
                            alignment: Alignment.center,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
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
          itemCount: dataFromPreferences.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> item = dataFromPreferences[index];
            return buildActivityItem(item, screenWidth);
          },
        ),
      ],
    );
  }
}

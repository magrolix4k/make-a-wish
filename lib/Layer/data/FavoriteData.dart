import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_connection.dart';
import '../widgets/ReuseableText.dart';
import '../Domain/PlaceDetailsPage.dart';

class FavoriteData extends StatefulWidget {
  const FavoriteData({Key? key}) : super(key: key);

  @override
  State<FavoriteData> createState() => _FavoriteDataState();
}

class _FavoriteDataState extends State<FavoriteData> {
  List<dynamic> dataFromDatabase = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserId = prefs.getString('user_id');
    if (savedUserId != null) {
      setState(() {
        userId = savedUserId;
      });
      fetchDataFromDatabase();
    }
  }

  Future<void> fetchDataFromDatabase() async {
    try {
      final url = Uri.parse(API.hostFavorite);
      final response = await http.post(
        url,
        body: {'user_id': userId!},
      );
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

  Future<void> deleteFavorite(String placeId, String userId) async {
    final url = Uri.parse(
        'https://makeawish.comsciproject.net/scifoxz/_deleteFavorite.php');

    try {
      final response = await http.post(
        url,
        body: {
          'place_id': placeId,
          'user_id': userId,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('ลบรายการที่เป็นที่โปรดสำเร็จ');
          final snackBar = SnackBar(content: Text('ลบรายการโปรดสำเร็จ'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            dataFromDatabase.removeWhere((item) => item['place_id'] == placeId);
          });
        } else {
          print('ไม่สามารถลบรายการที่เป็นที่โปรด');
        }
      } else {
        print('เกิดข้อผิดพลาดในการสื่อสารกับเซิร์ฟเวอร์');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาด: $error');
    }
  }

  void _navigateToPlaceDetails(
    BuildContext context,
    Map<String, dynamic> placeData,
  ) {
    Get.to(PlaceDetailsPage(placeData: placeData));
  }

  Widget buildPlaceItem(Map<String, dynamic> item, double screenWidth) {
    final double imageSize = screenWidth * 0.25;
    Uint8List imageBytes = base64Decode(item['place_image']);

    return GestureDetector(
      onTap: () {
        _navigateToPlaceDetails(context, item);
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
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
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
                        alignment: Alignment.center,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ReusableText(
                        text: item['place_nameHoly'],
                        size: screenWidth * 0.04,
                        alignment: Alignment.center,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ReusableText(
                        text: 'จ.' + item['place_province'],
                        size: screenWidth * 0.035,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(item['place_id']);
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
            return buildPlaceItem(item, screenWidth);
          },
        ),
      ],
    );
  }
  void _showDeleteConfirmationDialog(String place_id) {
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
                deleteFavorite(place_id, userId!);

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
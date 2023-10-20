import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api_connection.dart';
import '../widgets/ReuseableText.dart';
import 'PlaceDetailsPage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> dataFromDatabase = [];
  List<dynamic> dataFromPreferences = [];
  List<dynamic> comments = [];

  String? username;
  String? profile;
  String? userId;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedUserId = prefs.getString('user_id');
    final savedImage = prefs.getString('imageBase64');
    if (savedUsername != null && savedImage != null) {
      setState(() {
        username = savedUsername;
        profile = savedImage;
        userId = savedUserId;
      });
      final jsonData = prefs.getString('dashboard_data');
      if (jsonData != null) {
        final List<dynamic> cachedData = jsonDecode(jsonData);
        setState(() {
          dataFromPreferences = cachedData;
        });
      } else {
        fetchDataFromDatabase();
      }
      fetchDataFromComments();
    }
  }
  Future<void> fetchDataFromDatabase() async {
    try {
      final url = Uri.parse(API.hostPlaceData);
      final response = await http.post(url, body: {'username': username!});
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          dataFromDatabase = responseData;
        });
        saveDataToSharedPreferences(dataFromDatabase);
        updateDataWithAverageRatings();
      } else {
        print('ไม่สามารถดึงข้อมูลได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดขณะดึงข้อมูล: $error');
    }
  }


  Future<void> fetchDataFromComments() async {
    final url = Uri.parse(API.hostCommentData);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      comments = jsonDecode(response.body);
      updateDataWithAverageRatings();
    } else {
      print('ไม่สามารถดึงข้อมูลความคิดเห็นได้ รหัสสถานะ: ${response.statusCode}');
    }
  }

  void updateDataWithAverageRatings() {
    for (var item in dataFromPreferences) {
      final String placeId = item['place_id'];
      final double averageRating = calculateAverageRating(placeId);
      item['average_rating'] = averageRating;
    }
  }
  Future<void> saveDataToSharedPreferences(List<dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(data);
    await prefs.setString('dashboard_data', jsonData);
  }

  double calculateAverageRating(String placeId) {
    final ratingsForPlace =
        comments.where((comment) => comment['place_id'] == placeId);

    if (ratingsForPlace.isEmpty) {
      return 0.0;
    }

    final totalRating = ratingsForPlace.fold(0, (sum, comment) {
      final int rating =
          int.tryParse(comment['comment_rating'].toString()) ?? 0;
      return sum + rating;
    });

    return totalRating / ratingsForPlace.length;
  }

  void _navigateToPlaceDetails(
      BuildContext context, Map<String, dynamic> placeData) {
    Get.to(PlaceDetailsPage(placeData: placeData));
  }

  Widget buildPlaceItem(Map<String, dynamic> item, double screenWidth) {
    final Uint8List imageBytes = base64Decode(item['place_image']);
    final double imageSize = screenWidth * 0.25;

    double rating = item['average_rating'] ?? 0.0;
    String formattedRating = rating.toStringAsFixed(1);

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
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: screenWidth * 0.035,
                              ),
                              Text(
                                formattedRating.toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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
            return buildPlaceItem(item, screenWidth);
          },
        ),
      ],
    );
  }
}

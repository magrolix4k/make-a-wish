import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:makeawish/Layer/Domain/ActivityCreate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:share_plus/share_plus.dart';
import '../../main.dart';
import 'CommentDetailsPage.dart';
import 'CommentPage.dart';
import '../data/api_connection.dart';
import '../widgets/colors.dart';
import '../widgets/ActionButton.dart';
import '../widgets/CommentWidget.dart';
import '../widgets/ReuseableText.dart';
import 'OpenMap.dart';

class PlaceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> placeData;

  const PlaceDetailsPage({super.key, required this.placeData});

  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  String userId = '';
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
    _fetchComments();
    _savePlaceId(widget.placeData['place_id']);
    _saveLatLng(
      widget.placeData['place_id'],
      widget.placeData['place_latitude'],
      widget.placeData['place_longitude'],
    );

  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('user_id');

    setState(() {
      userId = storedUserId ?? '';
    });
  }

  Future<void> _fetchComments() async {
    final response = await http.post(Uri.parse(API.hostCommentData));

    if (response.statusCode == 200) {
      setState(() {
        comments = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  void _savePlaceId(String placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('place_id', placeId);
  }

  Future<void> _saveLatLng(
      String placeId, String latitude, String longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final latLngMap = {
      "latitude": latitude,
      "longitude": longitude,
    };
    await prefs.setString(placeId, jsonEncode(latLngMap));
    print('latitude: '' + $latitude + ' 'longitude: ' ' + $longitude');
  }

  Future<void> _handleFavorite() async {
    try {
      var response = await http.post(Uri.parse(API.hostAddFav), body: {
        "place_id": widget.placeData['place_id'],
        "user_id": userId,
      });
      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (res['success'] == true) {
          final snackBar = SnackBar(content: Text('เพิ่มรายการโปรด'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Future.delayed(Duration(milliseconds: 1000), () {
            Navigator.pop(context);
          });
        } else if (res['message'] == 'Place already in favorites') {
          final snackBar =
              SnackBar(content: Text('สถานที่นี้อยู่ในรายการโปรดอยู่แล้ว'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void _deleteComment(Map<String, dynamic> comment) async {
    final commentId = comment['comment_id'];

    try {
      final response = await http.post(
        Uri.parse(
            'https://makeawish.comsciproject.net/scifoxz/_deleteComment.php'),
        body: {
          'comment_id': commentId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success']) {
          setState(() {
            comments.remove(comment);
            Navigator.of(context).pop();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถลบความคิดเห็นได้'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการส่งคำขอหรือตอบสนอง: $e'),
        ),
      );
    }
  }
  void _editComment(Map<String, dynamic> comment) async{
    final commentId = comment['comment_id'];

    try {
      final response = await http.post(
        Uri.parse(
            'https://makeawish.comsciproject.net/scifoxz/_editComment.php'),
        body: {
          'comment_id': commentId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success']) {
          setState(() {
            comments.remove(comment);
            Navigator.of(context).pop();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถลบความคิดเห็นได้'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการส่งคำขอหรือตอบสนอง: $e'),
        ),
      );
    }
  }
  void _shareContent() async {
    final String text = widget.placeData['place_detail'];
    final Uint8List imageBytes = base64Decode(widget.placeData['place_image']);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(imageBytes);

    Share.shareFiles([tempFile.path], text: text+'#makeawish',);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double largeScreenWidth = 600;
    Uint8List imageBytes = base64Decode(widget.placeData['place_image']);

    double rating = widget.placeData['average_rating'] != null
        ? (widget.placeData['average_rating'] as num).toDouble()
        : 0.0;
    String formattedRating = rating.toStringAsFixed(1);
    print(formattedRating);

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
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        Get.to(MyHomePage());
                      });
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
                        text: widget.placeData['place_name'],
                        color: AppColors.mainColor,
                        size: screenWidth * 0.06,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      _handleFavorite();
                    },
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      child: Icon(FontAwesomeIcons.solidHeart,
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
            SizedBox(height: 8),
            Container(
              width: 350.0,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(CreateActivity(
                    userId: userId,
                    placeId: widget.placeData['place_id'],
                  ));
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.mainColor,
                ),
                child: Text('เพิ่มกิจกรรม',style: TextStyle(
                  color: Colors.black
                ),),
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
                        Row(
                          children: [
                            Icon(Icons.place, color: AppColors.mainColor),
                            SizedBox(width: 8),
                            Text(widget.placeData['place_province']),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: AppColors.mainColor),
                            SizedBox(width: 8),
                            Text('0' + widget.placeData['place_phone']),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule, color: AppColors.mainColor),
                            SizedBox(width: 8),
                            Text(widget.placeData['place_time']),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(
                          color: AppColors.mainColor,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: AppColors.mainColor),
                            SizedBox(width: 8),
                            Text((formattedRating != null)
                                ? (double.tryParse(formattedRating ?? '0') ?? 0).toString()
                                : '0')
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  margin:
                      EdgeInsets.only(right: 16, left: 16, bottom: 1, top: 1),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.mainColor),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'วิธีการไหว้',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: AppColors.mainColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.placeData['place_howto'],
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                  color: AppColors.mainColor, height: 20),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'ข้อมูลเพิ่มเติม',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold

                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                  color: AppColors.mainColor, height: 20),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.placeData['place_detail'],
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                  color: AppColors.mainColor, height: 20),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'การรีวิว',
                                style: TextStyle(
                                  fontSize: 16,
                                    fontWeight: FontWeight.bold

                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                  color: AppColors.mainColor, height: 20),
                            ),
                          ],
                        ),
                        // Use ListView.builder for comments
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            if (comment['place_id'] == widget.placeData['place_id']) {
                              String dateString = comment['created_at'];
                              DateTime dateTime = DateTime.parse(dateString);
                              return GestureDetector(
                                onTap: () {
                                  // _navigateToPlaceDetails(context, comment);
                                },
                                child: CommentWidget(
                                  commentId: comment['comment_id'],
                                  userAvatar: comment['comment_profile'],
                                  userName: comment['comment_username'],
                                  userRating:
                                      int.parse(comment['comment_rating']),
                                  commentText: comment['comment_comment'],
                                  commentTime: DateFormat('HH:mm:ss dd-MM-yyyy')
                                      .format(dateTime),
                                  image: comment['comment_images'],
                                  isUserComment: comment['user_id'] == userId,
                                  onEditComment: () {
                                    setState(() {
                                      _editComment(comment);
                                    });
                                  },
                                  onDeleteComment: () {
                                    _deleteComment(comment);
                                  },
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(CommentPage(context: context,));
                          },
                          child: Container(
                            height: 70,
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
                            child: Center(
                              child: Text(
                                'แสดงความคิดเห็นของคุณ...',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ActionButton(
                        icon: Icons.share,
                        label: 'แชร์',
                        onPressed: () {
                          _shareContent();
                        },
                      ),
                      ActionButton(
                        icon: Icons.directions,
                        label: 'เส้นทาง',
                        onPressed: () {
                          _navigateToGPS(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _navigateToGPS(BuildContext context) {
    Get.to(
      GotoGate(
        placeId: widget.placeData['place_id'],
        placeProvince: widget.placeData['place_name'],
        placeLatitude: widget.placeData['place_latitude'],
        placeLongitude: widget.placeData['place_longitude'],
      ),
    );
  }
}
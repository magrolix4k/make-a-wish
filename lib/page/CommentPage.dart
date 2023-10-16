import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Layer/data/api_connection.dart';
import '../utils/colors.dart';

class CommentPage extends StatefulWidget {
  final String? currentUsername;
  final String? currentPlace;
  final BuildContext context;

  const CommentPage(
      {Key? key,
      this.currentUsername,
      this.currentPlace,
      required this.context});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _commentController = TextEditingController();
  double _userRating = 0;
  String? _selectedImage;

  File? _imagepath;
  String? _imagename;
  String? _imagedata;

  String? _currentUsername;
  String? _currentUser_id;
  String? _currentPlace;

  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? currentPlace = prefs.getString('place_id');
    String? user_id = prefs.getString('user_id');
    if (savedUsername != null && user_id != null) {
      setState(() {
        _currentUsername = savedUsername;
        _currentUser_id = user_id;
        _currentPlace = currentPlace;
      });
      print('_currentUsername : ' + savedUsername);
      print('_currentUser_id : ' + user_id!);
      print('_currentPlace : ' + currentPlace!);
    }
  }

  Future<void> fetchCommentData() async {
    try {
      String commentText = _commentController.text;
      if (commentText.isNotEmpty && _userRating > 0) {
        DateTime currentTime = DateTime.now();
        String timestamp = currentTime.toIso8601String();

        var response = await http.post(Uri.parse(API.hostAddComment), body: {
          'place_id': _currentPlace,
          'user_id': _currentUser_id,
          'comment_text': commentText,
          'imageName': _imagename,
          'comment_image': _imagedata,
          'comment_rating': _userRating.toString(),
          'comment_timestamp': timestamp,
        });
        var res = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (res['success'] == true) {
            final snackBar = SnackBar(content: Text('สมัครสมาชิกสำเร็จ'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Future.delayed(Duration(milliseconds: 1000), () {
              Navigator.pop(context);
            });
          } else {
            final snackBar = SnackBar(content: Text('สมัครสมาชิกไม่สำเร็จ'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> _pickImage() async {
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imagepath = File(pickedImage.path);
        _imagename = pickedImage.path.split('/').last;
        _imagedata = base64Encode(_imagepath!.readAsBytesSync());
      });
      print(_imagepath);
      print(_imagename);
      print(_imagedata);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: _buildIconWithContainer(
                  Icons.keyboard_arrow_left,
                  Colors.white,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await _pickImage();
                  setState(() {
                    if (_imagepath != null) {
                      _selectedImage = _imagepath!.path;
                    }
                  });
                },
                child: _selectedImage != null
                    ? Image.file(File(_selectedImage!), height: 300)
                    : _buildAddPhotoContainer(),
              ),
              SizedBox(height: 20),
              _buildCommentInputContainer(),
              SizedBox(height: 20),
              _buildRatingIconsRow(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithContainer(IconData icon, Color color) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.1,
      height: screenWidth * 0.1,
      child: Icon(icon, color: color),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        color: AppColors.mainColor,
      ),
    );
  }

  Widget _buildAddPhotoContainer() {
    return Container(
      height: 100,
      color: Colors.grey,
      child: Center(
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildCommentInputContainer() {
    return Container(
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
        controller: _commentController,
        maxLines: 5,
        style: TextStyle(fontSize: 16.0, color: Colors.black),
        decoration: InputDecoration(
          hintText: 'แสดงความคิดเห็นของคุณ $_currentUsername...',
          hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }

  Widget _buildRatingIconsRow() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () {
            setState(() {
              _userRating = index + 1.toDouble();
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.005,
            ),
            child: Icon(
              _userRating >= index + 1 ? Icons.star : Icons.star_border,
              color: Colors.yellow,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        fetchCommentData();
      },
      child: Text('ส่งความคิดเห็น'),
    );
  }
}

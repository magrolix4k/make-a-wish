import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api_connection.dart';
import '../widgets/colors.dart';
import '../widgets/ReuseableText.dart';
import '../Presentation/ProfilePage.dart';

class EditProfilePage extends StatefulWidget {
  final String? currentUsername;
  final String? currentBirthday;
  final String? currentImg;

  const EditProfilePage({
    Key? key,
    this.currentUsername,
    this.currentBirthday,
    this.currentImg,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  File? _imagepath;
  String? _imagename;
  String? _imagedata;
  String? _currentUsername;
  AssetImage? _profileImage = AssetImage('assets/image/DPP.png');

  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.currentUsername!;
    _usernameController.text = _currentUsername!;
    _birthdayController.text = widget.currentBirthday!;
  }

  Future<void> _updateUserData() async {
    String newUsername = _usernameController.text.trim();
    String birthday = _birthdayController.text.trim();

    _imagedata = _imagepath != null
        ? base64Encode(_imagepath!.readAsBytesSync())
        : widget.currentImg;

    final response = await http.post(
      Uri.parse(API.hostEditUser),
      body: {
        'old_username': _currentUsername,
        'username': newUsername,
        'birthday': birthday,
        "data": _imagedata,
        "name": _imagename,
      },
    );

    var res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (res['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', newUsername);
        const snackBar = SnackBar(content: Text('แก้ไขสำเร็จ'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Future.delayed(const Duration(milliseconds: 1000), () {
          Get.to(ProfilePage());
        });
      } else {
        const snackBar = SnackBar(content: Text('แก้ไขเสร็จสิ้นไม่สำเร็จ'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
    }
  }
  Future<void> _pickBirthdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy/MM/dd').format(pickedDate);

      String day = DateFormat('dd').format(pickedDate);
      String month = DateFormat('MM').format(pickedDate);
      String yearBE = (int.parse(DateFormat('y').format(pickedDate)) + 543).toString();
      String formattedDates = '$day/$month/$yearBE';

      setState(() {
        _birthdayController.text = formattedDate;
        _birthdateController.text = formattedDates;
      });
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        color: AppColors.mainColor,
                      ),
                      child: const Icon(Icons.keyboard_arrow_left,
                          color: Colors.white),
                    ),
                  ),
                  Column(
                    children: [
                      ReusableText(
                        text: 'โปรไฟล์',
                        color: AppColors.mainColor,
                        size: screenWidth * 0.04,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showConfirmationDialog();
                        },
                        child: Container(
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.03),
                            color: AppColors.mainColor,
                          ),
                          child: const Icon(FontAwesomeIcons.penToSquare,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundImage: _imagepath != null
                            ? Image.memory(
                                _imagepath!.readAsBytesSync(),
                                fit: BoxFit.cover,
                              ).image
                            : _profileImage,
                        radius: screenWidth * 0.15,
                      )),
                  SizedBox(height: screenWidth * 0.02),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้',
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  InkWell(
                    onTap: _pickBirthdate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'วันเกิด',
                        border: UnderlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _birthdateController.text.isNotEmpty
                                ? _birthdateController.text
                                : 'เลือกวันเกิด',
                            style: TextStyle(
                                color: _birthdateController.text.isNotEmpty
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ยืนยันการแก้ไขข้อมูล'),
          content: Text('คุณแน่ใจหรือไม่ที่ต้องการแก้ไขข้อมูล?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _updateUserData();
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }
}

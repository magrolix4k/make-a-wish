import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/api_connection.dart';
import '../widgets/colors.dart';
import 'Login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  ImageProvider<Object>? profileImage = AssetImage('assets/image/DPP.png');
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();
  TextEditingController _birthdateControllers = TextEditingController();

  File? _imagepath;
  String? _imagename;
  String? _imagedata;

  ImagePicker imagePicker = ImagePicker();

  Future<void> _handleRegister() async {
    try {
      var response = await http.post(Uri.parse(API.hostUserRegister), body: {
        "username": _usernameController.text,
        "password": _passwordController.text,
        "birthdate": _birthdateController.text,
        "data": _imagedata,
        "name": _imagename,
      });
      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (res['success'] == true) {
          final snackBar = SnackBar(content: Text('สมัครสมาชิกสำเร็จ'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Future.delayed(Duration(milliseconds: 1000), () {
            Get.to(LoginPage());
          });
        } else {
          final message = res['message'];
          final snackBar = SnackBar(content: Text('มี Username นี้อยู่แล้ว'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (e) {
      print("เกิดข้อผิดพลาด : $e");
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
        _birthdateController.text = formattedDate;
        _birthdateControllers.text = formattedDates;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mainBlackColor, AppColors.mainColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("MakeAwish",
                    style: TextStyle(
                      color: AppColors.bBgColor,
                      fontFamily: 'IrishGrover',
                      fontWeight: FontWeight.w400,
                      fontSize: 50,
                    )),
                SizedBox(height: 20.0),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Signup",
                            style: TextStyle(
                              fontFamily: 'IrishGrover',
                              fontWeight: FontWeight.w400,
                              fontSize: 50,
                            )),
                        SizedBox(height: screenWidth * 0.04),
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundImage: _imagepath != null
                                ? FileImage(_imagepath!)
                                : profileImage,
                            radius: screenWidth * 0.15,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'ชื่อผู้ใช้'),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'รหัสผ่าน'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16.0),
                        InkWell(
                          onTap: _pickBirthdate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'วันเกิด',
                              border: UnderlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _birthdateControllers.text.isNotEmpty
                                      ? _birthdateControllers.text
                                      : 'เลือกวันเกิด',
                                  style: TextStyle(
                                      color:
                                          _birthdateController.text.isNotEmpty
                                              ? Colors.black
                                              : Colors.grey),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                            onPressed: _handleRegister,
                            child: Text('สมัครสมาชิก')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('ย้อนกลับ'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

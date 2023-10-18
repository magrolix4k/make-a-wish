import 'dart:convert';

import 'package:flutter/material.dart';
import '../Domain/ActivityLisview.dart';
import '../data/api_connection.dart';
import '../utils/colors.dart';
import '../widgets/ReuseableText.dart';


class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 50),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: "กิจกรรมของคุณ",
                      color: AppColors.mainColor,
                      size: screenWidth * 0.06,
                      alignment: Alignment.center,
                    ),
                    Row(
                      children: [
                        reusableText(
                          text: "ที่ได้เลือก",
                          color: Colors.black54,
                        ),
                        Icon(Icons.arrow_drop_down_rounded)
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ActivityListview(),
            ),
          ),
        ],
      ),
    );
  }
}
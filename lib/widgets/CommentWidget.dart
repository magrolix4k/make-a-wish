import 'dart:convert';

import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String userAvatar;
  final String userName;
  final int userRating;
  final String commentText;
  final String commentTime;
  final String image;
  final bool isUserComment; // ประกาศตัวแปร isUserComment ในพารามิเตอร์
  final Function() onEditComment; // ประกาศตัวแปร onEditComment ในพารามิเตอร์
  final Function()
      onDeleteComment; // ประกาศตัวแปร onDeleteComment ในพารามิเตอร์

  CommentWidget({
    required this.userAvatar,
    required this.userName,
    required this.userRating,
    required this.commentText,
    required this.commentTime,
    required this.image,
    required this.isUserComment,
    required this.onEditComment,
    required this.onDeleteComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: MemoryImage(base64Decode(userAvatar)),
                radius: 15,
              ),
              SizedBox(width: 10),
              Text(userName),
              SizedBox(width: 10),
              Spacer(),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(image)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(commentText),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                commentTime,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: List.generate(
              userRating,
              (index) => Icon(
                Icons.star,
                size: 16,
                color: Colors.yellow,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 190,
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: onEditComment, // เรียกใช้งานฟังก์ชันแก้ไขความคิดเห็น
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
              )
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจหรือไม่ที่ต้องการลบความคิดเห็นนี้?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: onDeleteComment,
              child: Text('ลบ'),
            ),
          ],
        );
      },
    );
  }
}

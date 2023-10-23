import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CommentWidget extends StatelessWidget {

  final String userAvatar;
  final String userName;
  final int userRating;
  final String commentText;
  final String commentTime;
  final String commentId;
  final String image;
  final bool isUserComment;
  final Function() onEditComment;
  final Function() onDeleteComment;

  CommentWidget({
    required this.userAvatar,
    required this.userName,
    required this.userRating,
    required this.commentText,
    required this.commentTime,
    required this.commentId,
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
                onPressed: () {
                  _editComment(context);
                },
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
  void _editComment(BuildContext context) {
    String commentids = commentId;
    String newCommentText = commentText;
    double newUserRating = userRating.toDouble();
    print(commentids);

    File? _imagepath;
    String? _imagename;
    String? _imagedata;

    ImagePicker imagePicker = ImagePicker();

    Future<void> _pickImage() async {
      var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
          _imagepath = File(pickedImage.path);
          _imagename = pickedImage.path.split('/').last;
          _imagedata = base64Encode(_imagepath!.readAsBytesSync());

        print(_imagepath);
        print(_imagename);
        print(_imagedata);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('แก้ไขความคิดเห็น'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: newCommentText,
                  onChanged: (text) {
                    newCommentText = text;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _pickImage();
                  },
                  child: Text('เลือกรูปภาพ'),
                ),
                RatingBar.builder(
                  initialRating: newUserRating.toDouble(),
                  minRating: 1,
                  itemSize: 20,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    newUserRating = rating;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _sendEditCommentRequest(commentids, newCommentText, _imagedata!,_imagename!, newUserRating);

                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _sendEditCommentRequest(String commentids, String newCommentText, String newImage,String _imagename, double newUserRating) async {
    try {
      final url = Uri.parse('https://makeawish.comsciproject.net/scifoxz/_editComment.php');
      DateTime currentTime = DateTime.now();
      String timestamp = currentTime.toIso8601String();

      var response = await http.post(url, body: {
        'comment_id' : commentids,
        'comment_text': newCommentText,
        'comment_timestamp': timestamp,
        'comment_image': newImage,
        'imageName' : _imagename,
        'comment_rating': newUserRating.toString(),
      });

      print('comment_id' + commentids);
      print('comment_text' + newCommentText);
      print('comment_timestamp' + timestamp);
      print('imageName' + _imagename);
      print('imageName' + newImage);
      print('comment_rating' + newUserRating.toString());

      var res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (res['success'] == true) {
          print('Success');
        } else {
          print('Not Success');
        }
      }else{
        print('Cant Connect');
      }
    }catch (e) {
      print("Exception: $e");
    }
  }
}
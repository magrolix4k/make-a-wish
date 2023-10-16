import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/colors.dart';
import '../widgets/ReuseableText.dart';

class CommentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> comment;
  final BuildContext context;

  const CommentDetailsPage(
      {Key? key, required this.comment, required this.context});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double largeScreenWidth = 600;

    Uint8List imageBytes = base64Decode(comment['c_images']);

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
                    child: _buildIconWithContainer(
                      Icons.keyboard_arrow_left,
                      Colors.white,
                    ),
                  ),
                  Column(
                    children: [
                      ReusableText(
                        text: 'ความคิดเห็นของ....',
                        color: AppColors.mainColor,
                        size: screenWidth * 0.04,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                  _buildIconWithContainer(
                    FontAwesomeIcons.solidHeart,
                    Colors.white,
                  ),
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
                child: _buildImageWithErrorHandling(imageBytes),
              ),
            ),
            _buildCommentDetailsCard(),
          ],
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

  Widget _buildImageWithErrorHandling(Uint8List imageBytes) {
    return Builder(
      builder: (BuildContext context) {
        try {
          return Image.memory(
            imageBytes,
            fit: BoxFit.contain,
          );
        } catch (e) {
          return Text("Image loading error: $e");
        }
      },
    );
  }

  Widget _buildCommentDetailsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.place, comment['c_comment']),
            _buildDetailRow(Icons.phone, comment['c_rating']),
            _buildDetailRow(Icons.schedule, comment['created_at']),
            SizedBox(height: 8),
            Divider(
              color: AppColors.mainColor,
            ),
            _buildDetailRow(Icons.star, comment['rating'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mainColor),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

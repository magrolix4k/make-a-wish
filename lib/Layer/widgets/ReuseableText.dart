import 'package:flutter/material.dart';

class ReusableText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  TextOverflow overFlow;

  ReusableText(
      {Key? key,
      this.color = const Color(0xFF332d2b),
      required this.text,
      required this.size,
      this.overFlow = TextOverflow.ellipsis,
      required Alignment alignment});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: overFlow,
      style: TextStyle(
          fontFamily: 'Kanit',
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w400),
    );
  }
}

class reusableText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;

  reusableText(
      {Key? key,
      this.color = const Color(0xFF332d2b),
      required this.text,
      this.size = 12,
      this.height = 1.2});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
          fontFamily: 'Kanit',
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w400,
          height: height),
    );
  }
}

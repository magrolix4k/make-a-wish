import 'package:flutter/material.dart';

import 'ReuseableText.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const IconText(
      {Key? key,
      required this.icon,
      required this.text,
      required this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),
        SizedBox(
          width: 5,
        ),
        reusableText(
          text: text,
        ),
      ],
    );
  }
}

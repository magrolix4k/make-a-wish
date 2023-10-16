import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  static const double iconSize = 24.0;
  static const double buttonWidth = 140.0;
  static const double buttonHeight = 50.0;
  RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );
  static const EdgeInsetsGeometry buttonPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainColor,
        shape: buttonShape,
        padding: buttonPadding,
        minimumSize: Size(buttonWidth, buttonHeight),
      ),
    );
  }
}

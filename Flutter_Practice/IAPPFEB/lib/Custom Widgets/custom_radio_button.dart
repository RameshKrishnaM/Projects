import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final Color color;
  const CustomRadioButton({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 2.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

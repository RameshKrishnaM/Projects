// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';

class CalculatorValueContainer extends StatelessWidget {
  final String text;
  final Color backGroundColor;
  final Color? textColor;
  const CalculatorValueContainer(
      {super.key,
      required this.text,
      required this.backGroundColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: backGroundColor, borderRadius: BorderRadius.circular(20.0)),
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontSize: 17.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

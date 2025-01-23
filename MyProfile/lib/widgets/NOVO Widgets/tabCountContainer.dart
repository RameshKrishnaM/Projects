// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

class TabinfoContainer extends StatelessWidget {
  TabinfoContainer({super.key, required this.tabCount});
  String tabCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
          border: Border.all(
            color: subTitleTextColor,
            width: 0.4,
            strokeAlign: 3,
          ),
          borderRadius: BorderRadius.circular(10),
          color: modifyButtonColor),
      child: Text(
        tabCount,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: titleTextColorLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kiro'),
      ),
    );
  }
}

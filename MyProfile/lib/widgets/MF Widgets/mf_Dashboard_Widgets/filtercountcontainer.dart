import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

class CustomMfFilterCountContianer extends StatelessWidget {
  final String filtercount;
  final bool isVisible;
  const CustomMfFilterCountContianer(
      {super.key, required this.filtercount, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        decoration: BoxDecoration(
            color: primaryGreenColor, borderRadius: BorderRadius.circular(10)),
        height: 15,
        width: 15,
        child: Center(
          child: Text(
            filtercount,
            style: TextStyle(color: titleTextColorDark, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

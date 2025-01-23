import 'package:ekycold/style.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color insideColor;
  final Color outsideColor;
  final Widget child;
  final double height;
  final double width;
  const CustomButton(
      {super.key,
      required this.insideColor,
      required this.height,
      required this.width,
      required this.outsideColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: insideColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: outsideColor,
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(4, 4)),
            BoxShadow(
                color: AppColors.light,
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(-4, -4))
          ]),
      child: Center(child: child),
    );
  }
}

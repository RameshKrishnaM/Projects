import 'package:ekycold/util/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButtonSmall extends StatelessWidget {
  var onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  CustomButtonSmall(
      {super.key,
      required this.onPressed,
      required this.child,
      this.backgroundColor,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      highlightColor: primaryColor.withOpacity(0.8),
      highlightElevation: 0,
      elevation: 0,
      // height: 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: primaryColor,
      onPressed: onPressed,
      child: child,
    );
  }
}

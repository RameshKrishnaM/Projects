import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final dynamic buttonWidget;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final dynamic onTapFunc;
  final bool? isSmall;
  final bool? buttonEnable;
  const CustomButton(
      {super.key,
      required this.buttonWidget,
      required this.onTapFunc,
      this.buttonEnable = true,
      this.borderColor,
      this.textColor,
      this.backgroundColor,
      this.isSmall});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isSmall ?? false ? 30.0 : 40.0,
      child: ElevatedButton(
          style: ButtonStyle(
              elevation: const MaterialStatePropertyAll(0),
              backgroundColor:
                  MaterialStatePropertyAll(backgroundColor ?? appPrimeColor),
              side: MaterialStatePropertyAll(borderColor == null
                  ? BorderSide.none
                  : BorderSide(color: borderColor ?? appPrimeColor)),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(isSmall ?? false ? 20.0 : 10.0)))),
          onPressed: onTapFunc,
          child: buttonWidget is String
              ? Text(
                  buttonWidget,
                  style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: isSmall ?? false ? 14.0 : 17.0,
                      fontWeight: FontWeight.w600),
                )
              : buttonWidget),
    );
  }
}

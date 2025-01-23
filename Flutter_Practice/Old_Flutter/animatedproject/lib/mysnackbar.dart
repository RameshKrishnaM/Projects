import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class CustomSnackBar extends StatefulWidget {
  const CustomSnackBar({super.key});

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            openSnackBar();
          },
          child: Text('Open SnackBar'),
        ),
      ),
    );
  }

  void openSnackBar() {
    Flushbar(
      animationDuration: const Duration(seconds: 2),
      forwardAnimationCurve:
          Curves.easeInOut, // 👈 Here you change the curve animation
      reverseAnimationCurve:
          Curves.easeInOut, // 👈 Here you change the curve animation
      duration: const Duration(milliseconds: 3000),
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      message: "I am Bottom Snackbar",
      margin: const EdgeInsets.symmetric(vertical: 20),
    ).show(context);
  }
}

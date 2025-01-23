import 'package:flutter/material.dart';

class MySnackBar extends StatelessWidget {
  final String message;
  final Color color;
  const MySnackBar({super.key, required this.message, required this.color});
  SnackBar openSnackBar() {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14.0, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

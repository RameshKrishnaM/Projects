import 'package:flutter/material.dart';

dynamic showSnackbar(dynamic context, String message, Color color) {
  ScaffoldMessenger.of(context).clearSnackBars();
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Row(
  //         children: [
  //           const Icon(Icons.check_circle, color: Colors.white),
  //           const SizedBox(width: 8),
  //           Text(message),
  //         ],
  //       ),
  //     ),
  //     backgroundColor: color,
  //     duration: const Duration(seconds: 3),
  //   ),
  // );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // duration: Duration(seconds: 8),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14.0, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
      elevation: 20,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(10.0))),
      behavior: SnackBarBehavior.fixed,
    ),
  );
}

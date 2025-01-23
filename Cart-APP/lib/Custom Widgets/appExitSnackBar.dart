import 'package:flutter/material.dart';

appExit(context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      duration: const Duration(seconds: 2),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/flattrade_logo.png",
            height: 25.0,
            width: 25.0,
          ),
          const SizedBox(
            width: 10.0,
          ),
          const Text(
            "Press again to Exit",
            style: TextStyle(fontSize: 17.0),
          )
        ],
      )));
}

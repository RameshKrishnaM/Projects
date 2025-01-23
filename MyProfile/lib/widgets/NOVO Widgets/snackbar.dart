import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

dynamic showSnackbar(BuildContext context, String message, Color color,
    {Color textColor = Colors.white}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: 14.0, color: textColor),
        textAlign: TextAlign.left,
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          left: 10,
          right: 10),
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      // behavior: SnackBarBehavior.fixed,
    ),
  );
}

appExit(context, String exitMessage) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.up,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.035,
          left: MediaQuery.of(context).size.width * 0.30,
          right: MediaQuery.of(context).size.width * 0.30),
      // dismissDirection: DismissDirection.horizontal,
      // width: 150,
      backgroundColor: titleTextColorLight,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      duration: const Duration(seconds: 2),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10.0,
          ),
          Text(
            exitMessage,
            style: TextStyle(fontSize: 14.0, color: titleTextColorDark),
          )
        ],
      )));
}

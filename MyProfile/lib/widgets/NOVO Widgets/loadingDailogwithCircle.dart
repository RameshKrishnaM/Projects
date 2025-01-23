// ignore_for_file: file_names, sort_child_properties_last

import 'package:flutter/material.dart';

loadingDailogWithCircle(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Dialog(
              elevation: 0,
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/NOVO loader.gif",
                  width: 50,
                  height: 50,
                ),
              ),
              backgroundColor: Colors.transparent));
    },
  );
}

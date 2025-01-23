// ignore_for_file: file_names

import 'package:flutter/material.dart';

loadingAlertBox(context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.7,
                child: Image.asset(
                  // "assets/Novo_Animation .gif",
                  // "assets/Novo_app_Logo.png"
                  "assets/NOVO loader.gif",
                  width: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              Text(message)
            ],
          ),
        ),
      );
    },
  );
}
  // padding: EdgeInsets.symmetric(
        //     horizontal: (MediaQuery.of(context).size.width - 350.0) / 2),
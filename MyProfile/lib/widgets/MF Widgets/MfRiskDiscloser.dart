// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/widgets/MF%20Widgets/Mf_Button_Widget.dart';

void showmfRiskDialog(
    {required context,
    required String title,
    required String discription,
    required var func}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close,
                size: 20,
              ),
            )
          ],
        ),
        content: Text(
          discription,
          textAlign: TextAlign.justify,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 13),
        ),
        actions: <Widget>[
          SizedBox(
              height: 30,
              child: CustomButton(
                  buttonWidget: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTapFunc: func)),
        ],
      );
    },
  );
}

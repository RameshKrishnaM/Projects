// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RichTextWidget extends StatelessWidget {
  const RichTextWidget(
      {super.key,
      required this.firstWidget,
      this.secondWidget,
      this.alignRight});
  final MainAxisAlignment? alignRight;
  final Widget firstWidget;
  final Widget? secondWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignRight ?? MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        firstWidget,
        if (secondWidget != null) secondWidget!,
      ],
    );
  }
}

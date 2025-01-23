import 'package:flutter/cupertino.dart';

import '../../utils/colors.dart';

class CustomSnackbarwithDelay extends StatelessWidget {
  final bool visible;
  final String value;
  final Color bgColor;
  final Widget? titleWidget;
  const CustomSnackbarwithDelay(
      {super.key,
      required this.visible,
      required this.value,
      required this.bgColor,
      this.titleWidget});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding:
            const EdgeInsets.only(top: 3, bottom: 5.0, left: 15, right: 15),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget == null ? const SizedBox() : titleWidget!,
            Text(
              value,
              style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: titleTextColorDark),
            ),
          ],
        ),
      ),
    );
  }
}

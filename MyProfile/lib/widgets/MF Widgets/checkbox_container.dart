import 'dart:math';
import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/colors.dart';
import 'package:provider/provider.dart';

class CustomCheckBoxContainer extends StatelessWidget {
  final bool isChecked;
  const CustomCheckBoxContainer({super.key, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 15.0,
          width: 15.0,
          decoration: BoxDecoration(
            border: Border.all(
                color: darkThemeMode ? titleTextColorDark : titleTextColorLight,
                width: 1),
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        Visibility(
          visible: isChecked,
          child: Positioned(
            left: 6,
            top: 3,
            child: Transform.rotate(
              angle: 135 * pi / 180,
              child: Container(
                  height: 5.0,
                  width: 15.0,
                  color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
        ),
        Visibility(
          visible: isChecked,
          child: Positioned(
            left: 4,
            bottom: 2,
            child: Transform.scale(
              scale: 1.5,
              child: Icon(
                Icons.check,
                size: 13.0,
                color: darkThemeMode ? Colors.blue : appPrimeColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}

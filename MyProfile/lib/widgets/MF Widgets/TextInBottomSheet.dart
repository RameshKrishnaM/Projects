// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:provider/provider.dart';

class CustomTextInBottomSheet extends StatelessWidget {
  final String text;
  const CustomTextInBottomSheet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    return Text(
      text,
      style: darkThemeMode
          ? ThemeClass.Darktheme.textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 14)
          : ThemeClass.lighttheme.textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }
}

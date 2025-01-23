import 'package:flutter/material.dart';

class ThemePack extends ChangeNotifier {
  Brightness currentBrightness = Brightness.light;

  void toggleTheme() {
    currentBrightness = currentBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
  }
}

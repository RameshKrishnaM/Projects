import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  bool isDarkMode = false;

  bool toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
    return isDarkMode;
  }
}

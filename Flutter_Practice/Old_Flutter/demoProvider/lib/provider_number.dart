import 'package:flutter/material.dart';

class Number_Provider extends ChangeNotifier {
  List numbers = [1, 2, 3, 4, 5];

  add() {
    int last = numbers.last;
    numbers.add(last + 1);
    notifyListeners();
  }
}

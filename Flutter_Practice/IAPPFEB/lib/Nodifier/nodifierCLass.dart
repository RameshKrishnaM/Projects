import 'package:flutter/material.dart';

class FormValidateNodifier extends ValueNotifier<Map> {
  FormValidateNodifier(super.value);
  Map get getValue => value;
  changeValue(Map newValue) {
    // print(newValue);
    value = newValue;
    notifyListeners();
  }
}

class ChangeDropDownValue extends ValueNotifier<String?> {
  ChangeDropDownValue() : super(null);
  changeValue(String newValue) {
    value = newValue;
  }
}

class TextFieldValueNodifier extends ChangeNotifier {
  String text = "";
  bool isValidated = false;
  TextFieldValueNodifier({this.text = ""});
  changeValue(String? newValue) {
    text = newValue ?? "";
    notifyListeners();
  }

  changeIsvalidated(bool value) {
    isValidated = value;
  }
}

class CheckBoxValueNodifier extends ValueNotifier {
  CheckBoxValueNodifier(super.value);
  bool get getValue => value;
  changeValue(bool newValue) {
    value = newValue;
  }
}

class DateChange extends ValueNotifier<DateTime?> {
  DateChange() : super(null);
  onchange(DateTime newDate) {
    value = newDate;
  }
}

class RadioButtonNodifier extends ValueNotifier<String?> {
  RadioButtonNodifier() : super(null);
  onchangeValue(String newValue) {
    value = newValue;
    notifyListeners();
  }
}

class ApplicationStatusNotifier extends ChangeNotifier {
  ApplicationStage _currentStage = ApplicationStage.completed;

  ApplicationStage get currentStage => _currentStage;

  void updateStage(ApplicationStage newStage) {
    if (_currentStage != newStage) {
      _currentStage = newStage;
      notifyListeners();
    }
  }
}

Color getColorForStage(ApplicationStage stage) {
  switch (stage) {
    case ApplicationStage.completed:
      return const Color.fromRGBO(50, 186, 124, 1);
    case ApplicationStage.rejected:
      return const Color.fromRGBO(234, 8, 8, 1);
    case ApplicationStage.inProgress:
      return const Color.fromRGBO(168, 168, 168, 1);
  }
}

String getTextForStage(ApplicationStage stage) {
  switch (stage) {
    case ApplicationStage.completed:
      return 'Completed';
    case ApplicationStage.rejected:
      return 'Rejected';
    case ApplicationStage.inProgress:
      return 'In progress';
  }
}

enum ApplicationStage { completed, rejected, inProgress }

class Span extends ChangeNotifier {
  bool _expanded = false;

  bool get expanded => _expanded;

  void setExpanded(bool value) {
    _expanded = value;
    notifyListeners();
  }
}

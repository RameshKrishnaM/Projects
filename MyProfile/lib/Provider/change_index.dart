import 'package:flutter/cupertino.dart';

class ChangeIndex extends ValueNotifier<int> {
  ChangeIndex._sharedIntances() : super(0);

  static final ChangeIndex _changeIndex = ChangeIndex._sharedIntances();
  factory ChangeIndex() => _changeIndex;
  int get getIndex => value;

  changeIndex(int newIndex) {
    value = newIndex;
    // notifyListeners();
  }
}

class MFChangeIndex extends ValueNotifier<int> {
  MFChangeIndex._sharedIntances() : super(0);

  static final MFChangeIndex _changeIndex = MFChangeIndex._sharedIntances();
  factory MFChangeIndex() => _changeIndex;
  int get getIndex => value;

  changeIndex(int newIndex) {
    value = newIndex;
    // notifyListeners();
  }
}

class ChangeNCBIndex extends ValueNotifier<int> {
  ChangeNCBIndex._sharedIntances() : super(0);

  static final ChangeNCBIndex _changeNCBIndex =
      ChangeNCBIndex._sharedIntances();
  factory ChangeNCBIndex() => _changeNCBIndex;
  int get getIndex => value;

  changeNCBIndex(int newIndex) {
    value = newIndex;
    ////////////print('NCBvalue');
    ////////////print(value);

    // notifyListeners();
  }
}

// class ChangeSGBIndex extends ValueNotifier<int> {
//   ChangeSGBIndex._sharedIntances() : super(0);

//   static final ChangeSGBIndex _changeSGBIndex =
//       ChangeSGBIndex._sharedIntances();
//   factory ChangeSGBIndex() => _changeSGBIndex;
//   int get getIndex => value;

//   changeSGBIndex(int newIndex) {
//     value = newIndex;
//     ////////////print('SGBvalue');
//     ////////////print(value);

//     // notifyListeners();
//   }
// }

class SgbTabCount extends ChangeNotifier {
  int sgbInvestCount = 0;
  int sgbOrderCount = 0;

  SgbTabCount._sharedIntences();
  static final SgbTabCount _tabIndex = SgbTabCount._sharedIntences();
  factory SgbTabCount() => _tabIndex;
  int get getsgbInvestCount => sgbInvestCount;
  int get getsgbOrderCount => sgbOrderCount;
  changesgbInvestCount(int newsgbInvestCount) {
    sgbInvestCount = newsgbInvestCount;
    notifyListeners();
  }

  changesgbOrderCount(int newsgbOrderCount) {
    sgbOrderCount = newsgbOrderCount;
    notifyListeners();
  }
}

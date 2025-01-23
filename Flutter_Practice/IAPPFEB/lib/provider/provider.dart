import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

// class Colorchange extends ChangeNotifier {
//   Future<FilePickerResult> pick1() async {
//     FilePickerResult? f1;
//     f1 = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'jpg', 'png'],
//         allowMultiple: false);
//     notifyListeners();
//     return f1!;
//   }

//   int age = 20;
//   DateTime? selectedDate;
//   List<String> names = [];
//   String? nominee1;
//   String? nominee2;
//   String? nominee3;
//   bool hieght = false;
//   bool? wish = true;
//   changenom1name({required String name, required String relation}) {
//     nominee1 = '$name ($relation)';
//     print(nominee1);
//     age = 20;
//     names.add(name);
//     notifyListeners();
//   }

//   changenom2name({required String name, required String relation}) {
//     nominee2 = '$name ($relation)';
//     names.add(name);
//     age = 20;
//     notifyListeners();
//   }

//   changenom3name({required String name, required String relation}) {
//     nominee3 = '$name ($relation)';
//     age = 20;
//     names.add(name);
//     notifyListeners();
//   }

//   radio(bool val) {
//     wish = val;
//     age = 20;
//     notifyListeners();
//   }

//   agecheck(DateChange dc) {
//     selectedDate = dc.value;
//     print(dc.value);
//     age = DateTime.now().year - selectedDate!.year;

//     if (DateTime.now().month < selectedDate!.month ||
//         (DateTime.now().month == selectedDate!.month &&
//             DateTime.now().day < selectedDate!.day)) {
//       age--;
//     }
//     print('${age}');
//   }
// }

// class son extends ChangeNotifier {
//   double switchon3 = 0;
//   double switchon2 = 0;
//   double switchon1 = 0;
//   bool button = false;
//   change3(double vue) {
//     switchon3 = vue;
//     button = false;
//     notifyListeners();
//   }

//   change2(double vue) {
//     switchon2 = vue;
//     button = false;
//     notifyListeners();
//   }

//   change1(double vue) {
//     switchon1 = vue;
//     button = false;
//     notifyListeners();
//   }

//   changebutton(bool val, int length) {
//     button = val;
//     if (button) {
//       if (length == 2) {
//         switchon1 = 50.00;
//         switchon2 = 50.00;
//       } else if (length == 3) {
//         switchon1 = 33.33;
//         switchon2 = 33.33;
//         switchon3 = 33.33;
//       }
//     }
//     notifyListeners();
//   }
// }

class Postmap extends ChangeNotifier {
  bool isNetworkConnected = true;
  List<Map<String, dynamic>> getresponse = [];
  List<Map<String, dynamic>> response = [];
  File? nFile1;
  File? nFile2;
  File? nFile3;
  File? gFile1;
  File? gFile2;
  File? gFile3;
  String nFileName1 = "";
  String nFileName2 = "";
  String nFileName3 = "";
  String gFileName1 = "";
  String gFileName2 = "";
  String gFileName3 = "";
  String mobileNo = "123";
  String email = "";
  List? errMsg;
  bool isEditPage = false;
  String url = '';
  bool allowModification = false;

  addmap(Map<String, dynamic> m) {
    response.add(m);
    notifyListeners();
  }

  changeResponse(List<Map<String, dynamic>> newResponse) {
    response = newResponse;
    notifyListeners();
  }

  changeGetResponse(List<Map<String, dynamic>> newResponse) {
    getresponse = newResponse;
    notifyListeners();
  }

  chenageResponseToEmpty() {
    response.clear();
  }

  changenFile(String name, File? file, String fileName, bool isNominee) {
    // print("file $file fileName $fileName");
    switch (name) {
      case "Nominee 1":
        isNominee ? nFile1 = file : gFile1 = file;
        isNominee ? nFileName1 = fileName : gFileName1 = fileName;
        break;
      case "Nominee 2":
        isNominee ? nFile2 = file : gFile2 = file;
        isNominee ? nFileName2 = fileName : gFileName2 = fileName;
        break;
      case "Nominee 3":
        isNominee ? nFile3 = file : gFile3 = file;
        isNominee ? nFileName3 = fileName : gFileName3 = fileName;
        break;
      default:
    }
    // print(gFIle1);
    // print(gFIleName1);
    notifyListeners();
  }

  getFile(String name, bool isNominee) {
    switch (name) {
      case "Nominee 1":
        return isNominee ? nFile1 : gFile1;
      case "Nominee 2":
        return isNominee ? nFile2 : gFile2;
      case "Nominee 3":
        return isNominee ? nFile3 : gFile3;
      default:
    }
    notifyListeners();
  }

  getFileName(String name, bool isNominee) {
    switch (name) {
      case "Nominee 1":
        return isNominee ? nFileName1 : gFileName1;
      case "Nominee 2":
        return isNominee ? nFileName2 : gFileName2;
      case "Nominee 3":
        return isNominee ? nFileName3 : gFileName3;
      default:
    }
    notifyListeners();
  }

  changeIsNetworkConnected(bool newValue) {
    isNetworkConnected = newValue;
    notifyListeners();
  }

  changeMobileNo(String newMobileNo) {
    mobileNo = newMobileNo;
    notifyListeners();
  }

  changeEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  changeErrMsg(List? newErrMsg) {
    errMsg = newErrMsg;
    notifyListeners();
  }

  changeIsEditPage(bool newIsEditPage) {
    isEditPage = newIsEditPage;
    notifyListeners();
  }

  changeUrl(String newUrl) {
    url = newUrl;
    notifyListeners();
  }

  changeAllowModification(bool newAllowModification) {
    allowModification = newAllowModification;
    notifyListeners();
  }
}

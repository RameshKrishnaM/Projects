import 'dart:io';

import 'package:flutter/material.dart';

class ProviderClass extends ChangeNotifier {
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

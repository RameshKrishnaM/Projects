import 'package:flutter/material.dart';
import 'package:novo/model/mfModels/mfschemeMasterDetails.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/widgets/NOVO%20Widgets/netWorkConnectionAlertBox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/MFAPICall.dart';

class NavigationProvider with ChangeNotifier {
  ThemeData currentTheme = ThemeClass.lighttheme;
  ThemeMode themeMode = ThemeMode.light;
  String cookies = '';
  String cookieTime = ''; // Default to system mode
  String pledgeableInfo = '';
  String sortOrder = 'NAMEASC';
  List<MfSchemeMasterArr> mfSchemeMasterFilterArr = [];
  int mfcartcount = 0;
  Map<String, dynamic> mfCheckActive = {};

  MfSchemeMasterDetails? mfSchemeMasterDetails;
  List<String> amcFilterArr = [];
  List<String> categoryFilterArr = [];
  String pledgableFilterKey = '';
  FocusNode focusNode = FocusNode();
  themeModel() {
    loadThemeFromPrefs();
  }

  void toggleTheme() {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
      currentTheme = ThemeClass.Darktheme;
    } else {
      themeMode = ThemeMode.light;
      currentTheme = ThemeClass.lighttheme;
    }
    saveThemeToPrefs();
    notifyListeners();
  }

  void loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme');

    if (savedTheme == 'dark') {
      themeMode = ThemeMode.dark;
      currentTheme = ThemeClass.Darktheme;
    } else if (savedTheme == 'light') {
      themeMode = ThemeMode.light;
      currentTheme = ThemeClass.lighttheme;
    }
    notifyListeners();
  }

  void saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeMode.toString().split('.').last);
  }

  getCookie() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    cookies = sref.getString("cookies") ?? "";
    cookieTime = sref.getString("cookieTime") ?? "";
    notifyListeners();
  }

  setCookies(String rawCookie, String newCookieTime) async {
    SharedPreferences sref = await SharedPreferences.getInstance();

    sref.setString("cookieTime", newCookieTime);
    sref.setString("cookies", rawCookie);
    cookies = rawCookie;
    cookieTime = newCookieTime;
    notifyListeners();
  }

  getmfmasterschemeApi(context) async {
    if (await isInternetConnected()) {
      try {
        mfSchemeMasterDetails = await fetchMfMasterDetails(
            context: context,
            amcFilterArr: amcFilterArr,
            categoryFilterArr: categoryFilterArr,
            pledgableFilterKey: pledgableFilterKey,
            sortOrder: sortOrder);
        changeMfSchemeMasterFilterArr(
            mfSchemeMasterDetails!.mfSchemeMasterArr!);
        notifyListeners();
      } catch (e) {
        print(e);
      }
    } else {
      noInternetConnectAlertDialog(
          context, () => getmfmasterschemeApi(context));
    }
  }

  changePledgeableInfo(String? newPledgeableInfo) {
    pledgeableInfo = newPledgeableInfo ?? "";
    notifyListeners();
  }

  changeMfSchemeMasterFilterArr(List<MfSchemeMasterArr> newMfSchemeMasterArr) {
    mfSchemeMasterFilterArr = newMfSchemeMasterArr;
    notifyListeners();
  }

  getmfCartcountAPI(context) async {
    var json = await fetchMfCartCount(context);
    ////print(json['mfcartcount']);
    if (json != null) {
      changeMfCartCount(json['mfcartcount'] ?? 0);
    } else {
      changeMfCartCount(0);
    }

    notifyListeners();
  }

  getMfCheckActivateAPI(context) async {
    var response = await fetchMfCheckActivate(context);

    if (response != null) {
      mfCheckActive = response;
    } else {
      mfCheckActive = {};
    }

    notifyListeners();
  }

  changeMfCartCount(int newMfcartCount) {
    mfcartcount = newMfcartCount;
    notifyListeners();
  }

  // getMFfilterData(List<String> newamcFilterArr,
  //     List<String> newcategoryFilterArr, List<String> pledgableFilterArr) {
  //   amcFilterArr = newamcFilterArr;
  //   categoryFilterArr = newcategoryFilterArr;
  //   pledgableFilterArr = pledgableFilterArr;
  //   notifyListeners();
  // }
}

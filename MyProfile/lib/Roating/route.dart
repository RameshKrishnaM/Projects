import 'package:flutter/material.dart';

import 'package:novo/model/ncbModels/ncbmasterModel.dart';
import 'package:novo/model/sgbModels/sgbdetailsmodel.dart';
import 'package:novo/screens/FlashScreen.dart';
import 'package:novo/screens/IPOscreens/IpoBidScreen.dart';

import 'package:novo/screens/NGBscreens/NcbPlaceOrderScreen.dart';
import 'package:novo/screens/SGBscreens/sgbplaceordersScreen.dart';
import 'package:novo/screens/loginwithpass.dart';

import 'package:page_transition/page_transition.dart';

import '../model/ipoModels/ipoMasterDetails.dart';
import '../screens/NOVOscreens/novoPage.dart';

// Route Names
const String logIn = 'logInPage';
const String novoPage = 'novoPage';
const String bidscreen = 'bidScreen';
const String modifyscreen = 'modifyScreen';
const String sgbplaceorderscreen = 'sgbplaceorderScreen';
const String ncbplaceorderscreen = 'ncbplaceorderscreen';
const String sgbmodifyscreen = 'sgbmodifyScreen';
const String ipoHistory = 'ipohistory';
const String flashScreen = 'flashScreen';

// Control our page route flow
Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case flashScreen:
      return PageTransition(
          duration: const Duration(milliseconds: 300),
          child: const FlashSCreenPage(),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center);
    case logIn:
      return PageTransition(
          duration: const Duration(milliseconds: 300),
          child: const LoginPage(),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center);
    case novoPage:
      return PageTransition(
          duration: const Duration(milliseconds: 300),
          child: NovoPage(),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center);

    case bidscreen:
      Map data = settings.arguments as Map;
      return PageTransition(
          duration: const Duration(milliseconds: 300),
          child: BidScreen(
            bidscreendetails: data['ipoDetail'] as IpoDetail,
            bidCategoryData: data['categoryList'] as CategoryList,
            suggestUPI: data['suggestUPI'],
          ),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center);

    case sgbplaceorderscreen:
      SgbDetail data = settings.arguments as SgbDetail;
      return PageTransition(
          duration: const Duration(milliseconds: 300),
          child: SgbPlaceOrder(
            sgbMasterDetails: data,
          ),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center);
    case ncbplaceorderscreen:
      Map data = settings.arguments as Map;
      return PageTransition(
          duration: const Duration(milliseconds: 300),
          child: NcbPlaceOrderScreen(
            index: data['index'],
            ncbMasterDetails: data['ncbMasterDetails'] as Detail,
          ),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center);

    default:
      throw ('This route name does not exit');
  }
}

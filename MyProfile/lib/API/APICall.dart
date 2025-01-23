// ignore_for_file: file_names, use_build_context_synchronously, unused_catch_clause, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/cookies/cookies.dart';
import 'package:novo/model/ipoModels/ipoMktDemandmodel.dart';
import 'package:novo/model/ncbModels/ncbHistoryModel.dart';
import 'package:novo/model/ncbModels/ncbmasterModel.dart';
import 'package:novo/model/sgbModels/sgbdetailsmodel.dart';
import 'package:novo/model/sgbModels/sgbhistorymodel.dart';
import 'package:novo/services/auth_mehods.dart';
import 'package:novo/services/biometricuserAuth.dart';
import 'package:novo/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Roating/route.dart' as route;
import 'package:http/http.dart' as http;
import '../model/ipoModels/ipoHistoryDetails.dart';
import '../model/ipoModels/ipoMasterDetails.dart';
import '../model/novoModels/dashboardmodel.dart';
import '../widgets/NOVO Widgets/snackbar.dart';

//This Fuction is post login details....
postLogInDetails({
  required BuildContext context,
  required String clientId,
  required String password,
  required String panCardNo,
  required String deviceName,
  required String deviceIP,
  // required bool deviceIsActive
}) async {
  String? isEnableBio = await BiometricAuthentication.getBiometricVerify();
  String enableAuth =
      BiometricAuthentication.isAuthenticated && isEnableBio == "Y" ? "Y" : "N";
  try {
    var bytes = utf8.encode(password);
    var hash = sha256.convert(bytes);
    Map postLogInDetails = {
      "clientId": clientId,
      "password": hash.toString(),
      "otp": panCardNo,
      "isBioMetric": enableAuth,
    };

    var response =
        await logInPost("webAuthlogin", jsonEncode(postLogInDetails), context);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json['status'] == 'S') {
        String res = await AuthMethods().getUserDetails(
          clientId: clientId,
          deviceName: deviceName,
          deviceIP: deviceIP,
        );
        //////////print(res);

        return json;
      } else if (json['status'] == 'E') {
        showSnackbar(
            context,
            json['errmsg'] == null || json['errmsg'].toString().isEmpty
                ? somethingError
                : json['errmsg'],
            Colors.red);
      } else if (json['status'] == 'I') {
        showSnackbar(
            context,
            json['errmsg'] == null || json['errmsg'].toString().isEmpty
                ? somethingError
                : json['errmsg'],
            Colors.red);
        // showSnackbar(context, sessionError, Colors.red);
        // ChangeIndex().value = 0;
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   route.logIn,
        //   (route) => false,
        // );
        // deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else {
      showSnackbar(context, '404 Error...', Colors.red);
    }
  } on SocketException catch (e) {
    showSnackbar(context, "PLE01$somethingError", Colors.red);
  } catch (e) {
    print(e);
    // showSnackbar(context, e.toString(), Colors.red);
  }
  return null;
}

//This Fuction is get the session Id for using the the sid in getotp and forget password...
getSessionId() async {
  Map<String, String> headers = {
    'Origin': 'https://auth.flattrade.in',
    'Referer': 'https://auth.flattrade.in'
  };
  try {
    var response = await http.post(
        Uri.parse("https://authapi.flattrade.in/auth/session"),
        headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    }
  } catch (e) {
    //////////print('Your SessionID Exception is $e');
  }
}

//This functions is used to post the details from the getotp then get the otp for login using otp..

postGetOtpDetails({
  required BuildContext context,
  required String panno,
  required String userId,
}) async {
  try {
    Map<String, dynamic> postGetOtpDetails = {
      "UserName": userId,
      "PAN": panno,
      "sid": "",
      "Sid": await getSessionId()
    };

    var response = await getOtpPost(jsonEncode(postGetOtpDetails), context);
    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body);
      if (res['emsg'] == "") {
        return true;
      } else {
        return res['emsg'];
      }
    }
  } catch (e) {
    showSnackbar(context, "PGOD01$somethingError", Colors.red);
  }
  return false;
}

//This Fuction is Used for the post the forgetpassword then get the forget password for login....
postForgetOtpDetails({
  required BuildContext context,
  required String panno,
  required String userId,
  required String dob,
}) async {
  try {
    Map<String, dynamic> postforgetpasswordDetails = {
      "UserName": userId,
      "PAN": panno,
      "DOB": dob,
      "Sid": await getSessionId(),
    };

    var response =
        await forgetPassPost(jsonEncode(postforgetpasswordDetails), context);

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body);
      if (res['emsg'] == "") {
        return true;
      } else {
        return res['emsg'];
      }
    }
  } catch (e) {
    showSnackbar(context, "PFPD01$somethingError", Colors.red);
  }
  return false;
}

//This Function is get the token from the api and validate the correct user and get the client Id...
validateToken(context) async {
  try {
    var response = await getMethod("tokenValidation", context);
    Map json = jsonDecode(response.body);

    if (json["status"] == "S") {
      return json['clientId'];
    } else if (json['status'] == 'E') {
      showSnackbar(
          context,
          json['errmsg'] == null || json['errmsg'].toString().isEmpty
              ? somethingError
              : json['errmsg'],
          Colors.red);
      //  showSnackbar(context, sessionError, Colors.red);
      // ChangeIndex().value = 0;
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   route.logIn,
      //   (route) => false,
      // );
      // deleteCookieInSref(context);
    } else if (json['status'] == 'I') {
      print('tokenExperied');
      showSnackbar(context, sessionError, Colors.red);
      ChangeIndex().value = 0;
      Navigator.pushNamedAndRemoveUntil(
        context,
        route.logIn,
        (route) => false,
      );
      deleteCookieInSref(context);
    } else {
      showSnackbar(context, somethingError, Colors.red);
    }
  } catch (e) {
    // showSnackbar(context, e.toString(), Colors.red);
  }
  // await deleteCookieInSref(context);
  // showSnackbar(context, 'Your session has expired...', primaryRedColor);
  // Navigator.pushNamed(context, route.logIn);
}

//This Function is get the Client Name From the Api...
getClientName(context) async {
  try {
    var response = await getMethod("getClientName", context);
    if (response != null && response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json["clientFullName"];
      }
    }
  } catch (e) {
    print(e);
    // showSnackbar(context,
    //     e.toString().isNotEmpty ? e.toString() : somethingError, Colors.red);
  }
  return null;
}

//This Fuction is used for Logout the user....
logout(context) async {
  try {
    // await Future.delayed(Duration(seconds: 5));
    var response = await logOutGet("logout", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        ChangeIndex().value = 0;
        MFChangeIndex().value = 0;
        // SharedPreferences sref = await SharedPreferences.getInstance();
        // // bool showBiometricDailog =
        // sref.setBool("isBiometricShow", true);
        // print(sref.getBool("isBiometricShow"));
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
        return true;
      } else if (json['status'] == 'E') {
        showSnackbar(
            context,
            json['errmsg'] == null || json['errmsg'].toString().isEmpty
                ? somethingError
                : json['errmsg'],
            Colors.red);
      } else if (json['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        MFChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else {
      showSnackbar(context, '${response.body ?? somethingError}', Colors.red);
    }
  } catch (e) {
    showSnackbar(context, "Lout01$somethingError", Colors.red);
  }
  return false;
}

//------------DashBoard Api..............
fetchNovoDashBoardDetails({required BuildContext context}) async {
  try {
    Map<String, String> headers = {
      'User-Agent': 'YourApp/1.0 (APP)', // Custom User-Agent header
    };
    final json = await getMethod('dashboard', context, header: headers);
    // //print(json.body);

    if (json != null && json.statusCode == 200) {
      NovoDashBoardDetails jsonResponse =
          novoDashBoardDetailsFromJson(json.body);

      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (jsonResponse.status == 'E') {
        showSnackbar(
            context,
            jsonResponse.errMsg == null ||
                    jsonResponse.errMsg.toString().isEmpty
                ? somethingError
                : jsonResponse.errMsg!,
            Colors.red);
      } else if (jsonResponse.status == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (json == null || json.statusCode != 200) {
      throw Exception('Failed to load SGB details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "FSD01$somethingError", Colors.red);
    ChangeIndex().value = 0;
    Navigator.pushNamedAndRemoveUntil(
      context,
      route.logIn,
      (route) => false,
    );
    deleteCookieInSref(context);
  } catch (e) {
    //////////print('Catch Error in Sgbmaster');
    //////////print(e.toString());
    // showSnackbar(context, e.toString(), Colors.red);
  }
  //////////print('NULl');
  return null;
}

//...................IPO API..........................

fetchIpoMasterDetails({required BuildContext context}) async {
  try {
    final json = await getMethod('getIpoMaster', context);
    // ////print(json.body);

    if (json != null && json.statusCode == 200) {
      IpoMasterDetails jsonResponse = ipoMasterDetailsFromJson(json.body);

      if (jsonResponse.status == "S") {
        // //print(jsonResponse);
        return jsonResponse;
      } else if (json['status'] == 'E') {
        showSnackbar(
            context,
            json['errmsg'] == null || json['errmsg'].toString().isEmpty
                ? somethingError
                : json['errmsg'],
            Colors.red);
      } else if (json['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (json == null || json.statusCode != 200) {
      throw Exception('Failed to load IPO details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "SCE02-$somethingError", Colors.red);
  } catch (e) {
    //////////print('Catch Error in IpoMaster');
    //////////print(e.toString());
    // showSnackbar(context, e.toString(), Colors.red);
  }
  //////////print('NULl');
  return null;
}

fetchIpoHistoryDetails({required BuildContext context}) async {
  try {
    final response = await getMethod('getIpoHistory', context);
    ////////print('response.body');
    ////////print(response.body);
    if (response != null && response.statusCode == 200) {
      IpoHistoryDetails jsonResponse = ipoHistoryDetailsFromJson(response.body);

      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (response['status'] == 'E') {
        showSnackbar(
            context,
            response['errmsg'] == null || response['errmsg'].toString().isEmpty
                ? somethingError
                : response['errmsg'],
            Colors.red);
      } else if (response['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (response == null || response.statusCode != 200) {
      throw Exception('Failed to load IPO History details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "SCE02-$somethingError", Colors.red);
  } catch (e) {
    //////////print('Catch Error in IpoHistory');
    //////////print(e.toString());
    // showSnackbar(context, e.toString(), Colors.red);
  }
  //////////print('NULl');
  return null;
}

fetchIpoMktDemand(
    {required BuildContext context, required int masterid}) async {
  try {
    final response =
        await getIpoMktDemandApi('getIpoMktData', masterid, context);
    ////////print(response.body);

    if (response != null && response.statusCode == 200) {
      IpoMktDemandModel jsonResponse = ipoMktDemandModelFromJson(response.body);

      if (jsonResponse.status == 'S') {
        return jsonResponse;
      } else if (response['status'] == 'E') {
        showSnackbar(
            context,
            response['errmsg'] == null || response['errmsg'].toString().isEmpty
                ? somethingError
                : response['errmsg'],
            Colors.red);
      } else if (response['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (response == null) {
      throw Exception('Failed to load IPO details');
    }
  } catch (e) {
    //////////print(e);
  }
}

ipoPlaceOrderApi(
    {required BuildContext context, required Map postBidDetails}) async {
  try {
    var placeOrderResponse =
        await postMethod('placeOrder', jsonEncode(postBidDetails), context);
    // //print('placeOrderResponse++++++++++++');
    // //print(placeOrderResponse.body);

    if (placeOrderResponse != null && placeOrderResponse.statusCode == 200) {
      Map placeOrderData = jsonDecode(placeOrderResponse.body);
      //////////print('********');
      //////////print(placeOrderData);
      // Map placeOrderData = placeOrderResponse.body;

      return placeOrderData;
    } else {
      Navigator.pop(context);
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    Navigator.pop(context);
    //////////print(e.toString());
    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}

//...................SGB API..........................

fetchSGBDetails({required BuildContext context}) async {
  try {
    final response = await getMethod('getSgbMaster', context);

    if (response != null && response.statusCode == 200) {
      SgbMasterDetail jsonResponse = sgbMasterDetailFromJson(response.body);

      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (response['status'] == 'E') {
        showSnackbar(
            context,
            response['errmsg'] == null || response['errmsg'].toString().isEmpty
                ? somethingError
                : response['errmsg'],
            Colors.red);
      } else if (response['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (response == null || response.statusCode != 200) {
      throw Exception('Failed to load SGB details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "SCE02-$somethingError", Colors.red);
  } catch (e) {
    showSnackbar(context, "FSGBD01$somethingError", Colors.red);
  }

  return null;
}

fetchSgbHistory({required BuildContext context}) async {
  //
  try {
    final response = await getMethod('sgb/getSgbHistory', context);

    if (response != null && response.statusCode == 200) {
      SgbHistory jsonResponse = sgbHistoryFromJson(response.body);
      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (response['status'] == 'E') {
        showSnackbar(
            context,
            response['errmsg'] == null || response['errmsg'].toString().isEmpty
                ? somethingError
                : response['errmsg'],
            Colors.red);
      } else if (response['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (response == null || response.statusCode != 200) {
      throw Exception('Failed to load SGB details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "SCE03-$somethingError", Colors.red);
  } catch (e) {
    showSnackbar(context, "SCE31-$somethingError", Colors.red);
  }

  return null;
}

sgbPlaceOrderApi(
    {required BuildContext context, required Map postBidDetails}) async {
  try {
    var placeOrderResponse =
        await postMethod('sgb/placeOrder', jsonEncode(postBidDetails), context);
    ////////print(placeOrderResponse.body);

    if (placeOrderResponse != null && placeOrderResponse.statusCode == 200) {
      Map placeOrderData = jsonDecode(placeOrderResponse.body);
      ////////print(placeOrderData);
      return placeOrderData;
    } else {
      Navigator.pop(context);
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    ////////print('SGB catch $e');
    Navigator.pop(context);

    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}

// deleteSgpPlaceorder(
//     {required BuildContext context, required Map deleteApp}) async {
//   try {
//     var response =
//         await postMethod('sgb/placeOrder', jsonEncode(deleteApp), context);

//     if (response != null && response.statusCode == 200) {
//       Map data = jsonDecode(response.body);

//       if (data['status'] == 'S') {
//         return true;
//       } else {
//         showSnackbar(
//             context, data['errMsg'] ?? somethingError, primaryRedColor);
//       }
//     } else if (response != null) {
//       Navigator.of(context).pop();
//       showSnackbar(context, "Failed to Delete the Details", primaryRedColor);
//     }
//   } catch (e) {
//     Navigator.of(context).pop();
//     showSnackbar(context, "DSPO01$somethingError", Colors.red);
//   }
//   return false;
// }
//---------------NCB API Calls----------------------

fetchNcbDetails({required BuildContext context}) async {
  try {
    final response = await getMethod('getNcbMaster', context);
    // //////////print('getNcbMaster');
    // //////////print(response.body);

    if (response != null && response.statusCode == 200) {
      NcbMasterDetails jsonResponse = ncbMasterDetailsFromJson(response.body);

      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (jsonResponse.status == 'E') {
        showSnackbar(
            context,
            jsonResponse.errMsg == null ||
                    jsonResponse.errMsg.toString().isEmpty
                ? somethingError
                : response['errmsg'],
            Colors.red);
      } else if (response['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (response == null || response.statusCode != 200) {
      throw Exception('Failed to load SGB details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "FSD01$somethingError", Colors.red);
  } catch (e) {
    //////////print('Catch Error in Sgbmaster');
    //////////print(e.toString());
    // showSnackbar(context, e.toString(), Colors.red);
  }
  //////////print('NULl');
  return null;
}

fetchNcbHistory({required BuildContext context}) async {
  //
  try {
    final response = await getMethod('getNcbOrderHistory', context);
    // //////////print('*******');
    // //////////print(response.body);

    if (response != null && response.statusCode == 200) {
      NcbHistoryModel jsonResponse = ncbHistoryModelFromJson(response.body);
      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (response['status'] == 'E') {
        showSnackbar(
            context,
            response['errmsg'] == null || response['errmsg'].toString().isEmpty
                ? somethingError
                : response['errmsg'],
            Colors.red);
      } else if (response['status'] == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, Colors.red);
      }
    } else if (response == null || response.statusCode != 200) {
      throw Exception('Failed to load NCB History details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "FSH01$somethingError", Colors.red);
  } catch (e) {
    //////////print(e.toString());

    // showSnackbar(context, e.toString(), Colors.red);
  }

  return null;
}

ncbPlaceOrderApi(
    {required BuildContext context, required Map postBidDetails}) async {
  try {
    var placeOrderResponse = await postMethod(
        'ncb/ncbPlaceOrder', jsonEncode(postBidDetails), context);

    if (placeOrderResponse != null && placeOrderResponse.statusCode == 200) {
      Map placeOrderData = jsonDecode(placeOrderResponse.body);
      // Map placeOrderData = placeOrderResponse.body;

      return placeOrderData;
    } else {
      Navigator.pop(context);
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    Navigator.pop(context);
    showSnackbar(context, "NPOA01$somethingError", primaryRedColor);
  }
  return null;
}

Future<void> setBioMetric({
  required BuildContext context,
  required Map<String, dynamic> bioMetric,
}) async {
  try {
    var response =
        await postMethod('bioMetricAuthVerify', jsonEncode(bioMetric), context);

    if (response.statusCode == 200) {
      updateCookie(response, context);
    }
  } catch (e) {
    print(e);
  }
}

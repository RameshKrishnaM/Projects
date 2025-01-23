import 'dart:convert';
import 'dart:typed_data';

import 'package:ekyc/Screens/signup.dart';
import 'package:ekyc/provider/provider.dart';
import 'package:ekyc/shared_preferences/shared_preference_func.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Cookies/cookies.dart';
import '../Custom Widgets/custom_snackbar.dart';
import '../Firebase_and_Facebook/event_capure.dart';
import '../Model/card_details_model.dart';
import '../Model/get_bank_detail_ifsc_model.dart';
import '../Model/get_bank_details_model.dart';
import "../Route/route.dart" as route;

exceptionShowSnackBarContent(content) {
  if (content.toString().startsWith("Exception:")) {
    content = content.toString().substring(10);
  }
  content = content.toString();
  if (content.contains("Network is unreachable")) {
    return "Network is unreachable";
  } else if (content.contains("Connection refused")) {
    return "Network Error";
  } else if (content.contains("ClientException with SocketException")) {
    return "Network Error.";
  } else if (content.contains("ClientException")) {
    return "Network Error..";
  } else if (content.contains("No internet")) {
    return "No internet";
  } else if (content.contains("session Expired")) {
    return "Session Expired";
  } else {
    return "some thing went wrong.";
  }
}

logout(context) async {
  loadingAlertBox(context);
  try {
    var response = await CustomHttpClient.get("clearCookie", context);
  } catch (e) {
    print("error $e");
  }
  await clearCookies();
  Navigator.pop(context);
  Navigator.pushNamedAndRemoveUntil(
      context, route.signup, (route) => route.isFirst);
}

error(code, context) {
  showSnackbar(context, "$code Some thing went wrong", Colors.red);
}

otpCallAPI({required json, required context}) async {
  try {
    var response = await CustomHttpClient.postWithOutCookie("newsendotp", json);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else if (json["statusCode"] == "NN") {
        return json["msg"];
      } else {
        showSnackbar(
            context, json["msg"] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

validateOTPAPI({required json, required context}) async {
  try {
    var response = await CustomHttpClient.logInPost("newOtpValidation", json);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      return json;
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getDropDownValues({required context, required code}) async {
  try {
    var response =
        await CustomHttpClient.getWithOutCookie("dropDowndata", {"code": code});

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

createConcentRequestAPI({required context, required data}) async {
  try {
    var response =
        await CustomHttpClient.post("AAconsentRequest", data, context);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getConcentStatus({required context, required data}) async {
  try {
    var response =
        await CustomHttpClient.post("AAconsentStatus", data, context);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (json['data']['status'] == 'S') {
        return json['data'];
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fetchStatement({required context, required data}) async {
  try {
    var response = await CustomHttpClient.post("getAAStatement", data, context);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return json;
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

checkStatementFetch({
  required context,
}) async {
  try {
    var response =
        await CustomHttpClient.post("AAValidationCheck", {}, context);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fetchCardDetailApi(BuildContext context) async {
  try {
    var response = await CustomHttpClient.get("infoCard", context);
    if (response.statusCode == 200) {
      CardDetailsModel cardDetailsModel =
          cardDetailsModelFromJson(response.body);
      if (cardDetailsModel.status == "S") {
        return cardDetailsModel;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context,
            cardDetailsModel.errMsg.isNotEmpty
                ? cardDetailsModel.errMsg
                : "some thing went wrong",
            Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

fetchBankDetailApi(BuildContext context) async {
  try {
    var response = await CustomHttpClient.get("BankDetails", context);
    if (response.statusCode == 200) {
      BankDetailsModel bankDetailsModel =
          bankDetailsModelFromJson(response.body);
      if (bankDetailsModel.status == "S") {
        return bankDetailsModel;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context,
            bankDetailsModel.errMsg.isNotEmpty
                ? bankDetailsModel.errMsg
                : "some thing went wrong",
            Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

postManualEntryDetailAPI({
  required BuildContext context,
  required json,
}) async {
  try {
    var response =
        await CustomHttpClient.post('manual_entry_process', json, context);

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body);
      if (res["status"] == "S") {
        return res;
      } else {
        showSnackbar(
            context, res["msg"] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    return exceptionShowSnackBarContent(e.toString());
  }

  return null;
}

fetchPersonalDetailFromApi(BuildContext context) async {
  try {
    var response = await CustomHttpClient.get("getPersonalDetails", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json["errMsg"] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

addPersInfo({required BuildContext context, required Map json}) async {
  try {
    var response =
        await CustomHttpClient.put("addPersonalDetails", json, context);

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body);
      if (res["status"] == "S") {
        return res;
      } else {
        showSnackbar(
            context, res["errMsg"] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    return exceptionShowSnackBarContent(e.toString());
  }
  return null;
}

getPANDetailsInAPI(context) async {
  try {
    var response = await CustomHttpClient.get("GetPanDetails", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

postPanNo({
  required context,
  required String panname,
  required String pannumber,
  required String pandob,
  required String verifyflag,
  required String digiid,
}) async {
  try {
    var response = await CustomHttpClient.post(
        "newpanstatus",
        {
          "panname": panname,
          "panno": pannumber,
          "pandob": pandob,
          "appname": "mobile",
          "verifyflag": verifyflag,
          "digiid": digiid,
        },
        context);
    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body);
      return res;
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

getAddressStatusAPI({required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.get("addressStatus", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

getAddressAPI({required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.get("getAddressNew", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

getPanAddressAPI({required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.get("getPanAddress", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        return "";
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

getDigiLockerAddressAPI({required BuildContext context}) async {
  try {
    var response =
        await CustomHttpClient.get("GetDigilockerInfoFromDb", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        return "";
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

insertKycInfoAPI({required json, required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.post("kycDetails", json, context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

insertDigiInfoAPI({required json, required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.post("addDlDetails", json, context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

insertPanDetails({required json, required BuildContext context}) async {
  try {
    loadingAlertBox(context);
    var response =
        await CustomHttpClient.post("insertpandetails", json, context);
    if (!context.mounted) {
      Navigator.pop(context);
    }
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

getTinValidateData({required json, required BuildContext context}) async {
  try {
    loadingAlertBox(context);
    var response =
        await CustomHttpClient.post("GetTinValidateData", json, context);
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(context, e.toString(), Colors.red);
    Navigator.pop(context);
  }
  return null;
}

getDigiLockerUrlAPI({required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.get(
        "constructDl_Url", context, {"appname": 'mobile'});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        if (!context.mounted) return;
        showSnackbar(
            context, json['msg'] ?? "some thing went wrong", Colors.red);
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

getBankDetailsAPI({required BuildContext context, required ifscCode}) async {
  try {
    var response = await CustomHttpClient.put(
        "IfscDetails", {"ifsccode": ifscCode}, context);
    if (response.statusCode == 200) {
      FetchBankDetailByIfsc fetchBankDetailByIfsc =
          fetchBankDetailByIfscFromJson(response.body);
      if (fetchBankDetailByIfsc.status == "S") {
        return fetchBankDetailByIfsc;
      }
    } else {
      error(response.statusCode, context);
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

insertBankDetailsAPI({required context, required json}) async {
  try {
    var response = await CustomHttpClient.put("addBankDetail", json, context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["errmsg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getBankWithAccountDetailsAPI({required context}) async {
  try {
    var response = await CustomHttpClient.get("getBankDetails", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["errmsg"] ?? "some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

proofUploadAPI({required context, required headerMap, required files}) async {
  try {
    var response = await CustomHttpClient.uploadProof(
        context, "proofUploads", files, headerMap);
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      Map json = jsonDecode(responseBody);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["errmsg"] ?? "some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fileUploadPostAPI({required context, required json}) async {
  try {
    var response =
        await CustomHttpClient.post("ProofFileInsert", json, context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["errmsg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fileUploadAPI({required context, required headerMap, required files}) async {
  try {
    var response = await CustomHttpClient.uploadFiles(
        context, "FileUploads", files, headerMap);
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      Map json = jsonDecode(responseBody);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

singleFileUploadAPI(
    {required context, required headerMap, required files}) async {
  try {
    var response = await CustomHttpClient.uploadFiles(
        context, "SingleFileUploads", files, headerMap);

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map json = jsonDecode(responseBody);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getNomineeAPI({required context}) async {
  try {
    var response = await CustomHttpClient.post("getNomineeData", "", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["errMsg"] ?? "some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

addNomineeAPI(
    {required context, required deleteIds, required inputJsonData}) async {
  try {
    var response = await CustomHttpClient.addNomineePost(
        context, "addNewNomineeData", deleteIds, inputJsonData);
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map json = jsonDecode(responseBody);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["errmsg"] ?? "some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fetchFileIdAPI({required context}) async {
  try {
    var response = await CustomHttpClient.get("getProofDetails", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fetchFile({required context, required String id, bool list = false}) async {
  try {
    var response = await CustomHttpClient.get("pdffile?id=$id", context);
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      if (!list) {
        return bytes;
      } else {
        return [response.headers["filename"], bytes];
      }
    } else {
      showSnackbar(context,
          exceptionShowSnackBarContent("Some thing went wrong"), Colors.red);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

fetchFile1({required context, required String id, bool list = false}) async {
  try {
    var response = await CustomHttpClient.get("downloadFile?id=$id", context);
    if (response.statusCode == 200) {
      Map m = jsonDecode(response.body);
      var a = base64Decode(m["file"]);
      return a;
    } else {
      throw Exception("Some thing went wrong");
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

Future<Uint8List> fetchFileType({required context, required String id}) async {
  try {
    var response = await CustomHttpClient.get("pdffile?id=$id", context);
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;

      return bytes;
    } else {
      throw Exception("Some thing went wrong");
    }
  } catch (e) {
    throw Exception(exceptionShowSnackBarContent(e.toString()));
  }
}

generatePdf({required context}) async {
  try {
    var response = await CustomHttpClient.post(
      "GeneratePdf",
      "",
      context,
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
        return json["msg"];
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
    return "Some thing went wrong";
  }
}

initiateEsign({required context}) async {
  try {
    var response = await CustomHttpClient.get(
      "",
      context,
      {},
    );
    return response;
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getDishClosureData({required context, required contentType}) async {
  try {
    var response = await CustomHttpClient.get(
        "getriskdisclosure", context, {"contenttype": contentType});

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

riskdisclosureinsertInAPI(
    {required BuildContext context, required json}) async {
  try {
    var response = await CustomHttpClient.post(
      "riskdisclosureinsert",
      json,
      context,
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

checkEsignCompletedInAPI({required context}) async {
  var response = await CustomHttpClient.get(
    "sign/CheckEsigneCompleted",
    "",
    context,
  );

  if (response.toString().isNotEmpty) {
    Map json = jsonDecode(response.body);

    if (json["status"] == "S") {
      return json;
    }
  }
}

formSubmissionAPI({required context}) async {
  try {
    var response = await CustomHttpClient.post(
      "formSubmission",
      "",
      context,
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getDigiInfoAPI({required context, required String digiId, required url}) async {
  try {
    var response = await CustomHttpClient.post(
      "getDlInfo",
      {"digi_id": digiId, "url": url},
      context,
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getIPVDetailsAPI({required context}) async {
  try {
    var response = await CustomHttpClient.get("getIpvDetails", context);

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getUserDetailsForIPVInAPI({required context}) async {
  try {
    var response = await CustomHttpClient.post("ipvRequest", "", context);

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

ipvRecapture({required context, required String actiontype}) async {
  try {
    var response = await CustomHttpClient.get(
        "ipvRecapture", context, {"ActionType": actiontype});

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

saveIPVDetailsInAPI(
    {required context, required json, required actiontype}) async {
  try {
    (json);
    var response = await CustomHttpClient.post(
        "getDigiDocs", json, context, {"ActionType": actiontype});

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getUserDetailsForEsignInAPI({required context}) async {
  try {
    var response = await CustomHttpClient.get(
      "esignrequ",
      context,
      {},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

checkCDSLEsign({required context}) async {
  try {
    var response = await CustomHttpClient.get("checkCdslEsign", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      print("json***");
      print(json);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

savecdslesign({required context}) async {
  try {
    var response = await CustomHttpClient.get("savecdslesign", context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      print("savecdslesignjson***");
      print(json);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

saveEsignInAPI({required context, required digid}) async {
  try {
    var response = await CustomHttpClient.get(
      "saveesignfile",
      context,
      {"digid": digid},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getServeBrokerDetailsApi(BuildContext context) async {
  try {
    var response = await CustomHttpClient.get('GetDematandService', context);
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

insertDemantserveApi(BuildContext context, Map demantServe) async {
  try {
    var response =
        await CustomHttpClient.post("DematServeInsert", demantServe, context);
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getReviewDetails({required BuildContext context}) async {
  try {
    var response = await CustomHttpClient.get("getReviewDetailsNew", context);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getPincode({required context, required pincode}) async {
  try {
    var response =
        await CustomHttpClient.get("pincode", context, {"pincode": pincode});
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getClientAddressInAPI({required context}) async {
  try {
    var response = await CustomHttpClient.get("asClientAddress", context);
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      }
    } else {
      showSnackbar(context, json["msg"] ?? "Some thing went wrong", Colors.red);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getRouteInfoInAPI({required context}) async {
  try {
    var response = await CustomHttpClient.get("routerinfo", context);
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      }
    } else {
      showSnackbar(context, json["msg"] ?? "Some thing went wrong", Colors.red);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getRouteNameInAPI({required context, required data}) async {
  try {
    ProviderClass provider = Provider.of<ProviderClass>(context, listen: false);

    if (provider.isEditPage) {
      provider.changeIsEditPage(false);
      return {"endpoint": route.review};
    }
    var response = await CustomHttpClient.post("routerflow", data, context);

    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        if (data["routeraction"] == "Next") {
          provider.changeErrMsg(json["message"]);
          await insertRouteNameInFireBase(
              context: context, newRouteName: json["routername"]);
        }
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getFormStatus({required context}) async {
  try {
    var response = await CustomHttpClient.get("getFormStatus", context);
    var json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      }
    } else {
      showSnackbar(context, json["msg"] ?? "Some thing went wrong", Colors.red);
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

getAppVersionInAPI({required context}) async {
  try {
    var response = await CustomHttpClient.getWithOutCookie("getappversion");
    var json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (json['status'] == 'S') {
        return json;
      } else {
        showSnackbar(
            context, json["msg"] ?? "Some thing went wrong", Colors.red);
      }
    }
  } catch (e) {
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
}

bool jsonIsModified(Map oldJson, Map newJson) {
  bool res = newJson.keys.every((element) {
    return newJson[element] == oldJson[element];
  });

  return !res;
}

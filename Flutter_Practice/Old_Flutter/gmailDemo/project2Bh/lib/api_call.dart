import 'dart:convert';

import 'package:ekycproject/Cookies/cookies.dart';
import 'package:ekycproject/Model/state_model.dart';
import 'package:ekycproject/widget/custom_snackBar.dart';
import 'package:flutter/material.dart';

logout(context) {}

otpCallAPI({required json}) async {
  var response = await putWithOutCookie("api/otpcall", json);
  return response;
}

validateOTPAPI({required json}) async {
  var response = await putWithOutCookie("api/validotp", json);
  return response;
}

getStateAPI() async {
  var response = await postWithOutCookie("api/dropDowndata", [
    {"code": "state", "description": "state Name"}
  ]);
  return response;
}

// fetchCardDetailApi(BuildContext context) async {
//   try {
//     var response = await get("CardDetails", context);
//     print(response.body);
//     if (response.statusCode == 200) {
//       CardDetailsModel cardDetailsModel =
//           cardDetailsModelFromJson(response.body);
//       if (cardDetailsModel.status == "S") {
//         return cardDetailsModel;
//       } else {
//         if (!context.mounted) return;
//         showSnackbar(context, cardDetailsModel.errMsg, Colors.red);
//       }
//     }
//   } catch (e) {
//     if (!context.mounted) return;
//     showSnackbar(
//         context, exceptionShowSnackBarContent(e.toString()), Colors.red);
//   }
//   return null;
// }

fetchBankDetailApi(BuildContext context) async {
  try {
    var response = await get("BankDetails", context);
    print(response.body);
    if (response.statusCode == 200) {
      BankDetailsModel bankDetailsModel =
          bankDetailsModelFromJson(response.body);
      if (bankDetailsModel.status == "S") {
        return bankDetailsModel;
      } else {
        if (!context.mounted) return;
        showSnackbar(context, bankDetailsModel.errMsg, Colors.red);
      }
    }
  } catch (e) {
    if (!context.mounted) return;
    showSnackbar(
        context, exceptionShowSnackBarContent(e.toString()), Colors.red);
  }
  return null;
}

// fetchPersonalDetailFromApi(BuildContext context) async {
//   try {
//     var response = await get("PersonalDetails", context);
//     print(response.body);
//     if (response.statusCode == 200) {
//       PersonalDetailModel personalDetailModel =
//           personalDetailModalFromJson(response.body);

//       if (personalDetailModel.status == "S") {
//         return personalDetailModel;
//       } else {
//         if (!context.mounted) return;
//         showSnackbar(context, personalDetailModel.errMsg, Colors.red);
//       }
//     }
//   } catch (e) {
//     if (!context.mounted) return;
//     showSnackbar(
//         context, exceptionShowSnackBarContent(e.toString()), Colors.red);
//   }
//   return null;
// }

addPersInfo({
  required BuildContext context,
  required String maritalStatus,
  required String gender,
  required String emailOwner,
  required String phoneOwner,
  required String fatherName,
  required String motherName,
  required String annualIncome,
  required String tradingExperience,
  required String occupation,
  required String politicalExpo,
  required String education,
  required String nomineeOpted,
}) async {
  try {
    var response = await put(
        "InsertDetails",
        // PersInfoModel(
        //     maritalStatus: maritalStatus,
        //     gender: gender,
        //     emailOwner: emailOwner,
        //     phoneOwner: phoneOwner,
        //     fatherName: fatherName,
        //     motherName: motherName,
        //     annualIncome: annualIncome,
        //     tradingExperience: tradingExperience,
        //     occupation: occupation,
        //     politicalExpo: politicalExpo,
        //     education: education,
        //     nomineeOpted: nomineeOpted),
        {
          "maritalStatus": maritalStatus,
          "gender": gender,
          "emailOwner": emailOwner,
          "phoneOwner": phoneOwner,
          "fatherName": fatherName,
          "motherName": motherName,
          "annualIncome": annualIncome,
          "tradingExperience": tradingExperience,
          "occupation": occupation,
          "politicalExpo": politicalExpo,
          "education": education,
          "nomineeOpted": nomineeOpted
        },
        context);
    print("response.body ${response.body}");

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body);
      if (res["status"] == "S") {
        return "success";
      } else {
        return res["errMsg"];
      }
    }
  } catch (e) {
    print("EXCEPTION IN PUT: $e");
    // return exceptionShowSnackBarContent(e.toString());
  }
  return null;
}

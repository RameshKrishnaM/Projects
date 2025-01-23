import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:novo/Provider/change_index.dart';
import 'package:novo/cookies/cookies.dart';

import 'package:novo/model/mfModels/mfpurchaseConfigDetails.dart';
import 'package:novo/model/mfModels/mfschemeMasterDetails.dart';

import 'package:novo/utils/colors.dart';
import '../Roating/route.dart' as route;

import '../model/mfModels/Mf_cart_data.dart';
import '../model/mfModels/mf_holding_data.dart';
import '../model/mfModels/mf_pieChart_Model.dart';
import '../model/mfModels/mf_transactionStatus_model.dart';
import '../model/mfModels/mf_transaction_data.dart';
import '../widgets/NOVO Widgets/snackbar.dart';

//-------------------------MF API's--------------------------------------

/* 
Method Name: fetchMfCheckActivate
Purpose : Check the MF is Enable or Not then check the API and Allowed to invest MF
EndPoint: mf/CheckClientMfStatus
API Method: POST
body: ""
Parameter : context
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse for check the MFActive Enable Or Not

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfCheckActivate(+)
fetchMfCheckActivate(context) async {
  try {
    final json = await postMethod('mf/CheckClientMfStatus', '', context,
        header: {"TYPE": "DASHBOARD"});

    if (json != null && json.statusCode == 200) {
      var jsonresponse = jsonDecode(json.body);

      if (jsonresponse['status'] == "S" ||
          jsonresponse['status'] == "W" ||
          jsonresponse['status'] == "R" ||
          jsonresponse['status'] == 'E') {
        return jsonresponse;
      }
      // else if (jsonresponse['status'] == 'E') {
      //   print(jsonresponse['status']);
      // }

      else if (jsonresponse['status'] == 'I') {
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
    }
  } catch (e) {
    showSnackbar(context, "FMCA01F-$somethingError", Colors.red);
  }

  return null;
}
//fetchMfCheckActivate(-)

/* 
Method Name: fetchMfBoActivate
Purpose :This API is post the Accept request for MF activation Enable the Back Office
EndPoint: mf/DirectClientActivation
API Method: POST
body: ""
Parameter : context
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse for check the MF activation Enable the Back Office
On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/

//fetchMfBoActivate(+)

fetchMfBoActivate(context, data) async {
  try {
    final json = await postMethod('mf/DirectClientActivation', data, context);
    if (json != null && json.statusCode == 200) {
      var jsonresponse = jsonDecode(json.body);
      if (jsonresponse['status'] == "S") {
        return jsonresponse;
      } else if (jsonresponse['status'] == 'E') {
        showSnackbar(
            context,
            jsonresponse['status'] == null ||
                    jsonresponse['errMsg'].toString().isEmpty
                ? somethingError
                : jsonresponse['errMsg'].toString(),
            Colors.red);
      } else if (jsonresponse['status'] == 'I') {
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
    }
  } catch (e) {
    showSnackbar(context, "FMBA01F-$somethingError", Colors.red);
  }

  return null;
}
//fetchMfBoActivate(-)

/* 
Method Name: fetchMfDisclimarPop
Purpose :This API is check the Mf Dislaimer show the client until the accept the terms.
EndPoint: mf/disclaimerPopup
API Method: POST
body: ""
Parameter : context
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse for check the client status of Accept the Disclaimer
On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/

//fetchMfDisclimarPop(+)
fetchMfDisclimarPop(context) async {
  try {
    final json = await postMethod('mf/disclaimerPopup', '', context);

    if (json != null && json.statusCode == 200) {
      var jsonresponse = jsonDecode(json.body);
      if (jsonresponse['status'] == "S") {
        return jsonresponse;
      } else if (jsonresponse['status'] == 'E') {
        showSnackbar(
            context,
            jsonresponse['status'] == null ||
                    jsonresponse['errMsg'].toString().isEmpty
                ? somethingError
                : jsonresponse['errMsg'].toString(),
            Colors.red);
      } else if (jsonresponse['status'] == 'I') {
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
      throw Exception('Failed to load fetchMfDisclaimerPop details');
    }
  } catch (e) {
    showSnackbar(context, "FMDP01F-$somethingError", Colors.red);
  }
  return null;
}
//fetchMfDisclimarPop(-)

/* 
Method Name: fetchMfDisclimarFlag
Purpose :This API is post the 'Y' for Accept the Terms for MfDislaimer
EndPoint: mf/disclaimerFlagUpdate
API Method: POST
body: {"disclaimerflag": "Y"}
Parameter : context,reqDetails
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse for check the client status of Accept the Disclaimer
On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/

//fetchMfDisclimarFlag(+)

fetchMfDisclimarFlag(context, Map reqDetails) async {
  try {
    final json = await postMethod(
        'mf/disclaimerFlagUpdate', jsonEncode(reqDetails), context);

    if (json != null && json.statusCode == 200) {
      var jsonresponse = jsonDecode(json.body);
      print(jsonresponse);

      if (jsonresponse['status'] == "S") {
        return jsonresponse;
      } else if (jsonresponse['status'] == 'E') {
        showSnackbar(
            context,
            jsonresponse['status'] == null ||
                    jsonresponse['errMsg'].toString().isEmpty
                ? somethingError
                : jsonresponse['errMsg'].toString(),
            Colors.red);
      } else if (jsonresponse['status'] == 'I') {
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
    }
  } catch (e) {
    showSnackbar(context, "FMDF01F-$somethingError", Colors.red);
  }
  return null;
}
//fetchMfDisclimarFlag(-)

/* 
Method Name: fetchMfFooterValue
Purpose : fetchFooterValue for get the footer content and show the dash board footer
EndPoint: mf/getDisclaimerData
API Method: POST
body: {"key": "MfFooter"}
Parameter : context
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse for show the Footer Value
On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfFooterValue(+)
fetchMfFooterValue(context) async {
  try {
    final json = await postMethod(
        'mf/getDisclaimerData', jsonEncode({"key": "MfFooter"}), context);
    if (json != null && json.statusCode == 200) {
      var jsonresponse = jsonDecode(json.body);

      if (jsonresponse['status'] == "S") {
        return jsonresponse;
      } else if (jsonresponse['status'] == 'E') {
        showSnackbar(
            context,
            jsonresponse['status'] == null ||
                    jsonresponse['errMsg'].toString().isEmpty
                ? somethingError
                : jsonresponse['errMsg'].toString(),
            Colors.red);
      } else if (jsonresponse['status'] == 'I') {
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
    }
  } catch (e) {
    showSnackbar(context, "FFV01F-$somethingError", Colors.red);
  }

  return null;
}
//fetchMfFooterValue(-)

//MF Explore Screen..........

/* 
Method Name: fetchMfMasterDetails
Purpose : This API used to Get the MFSchemeMaster Details show the Explore Screen
EndPoint: mf/schemeMaster
API Method: POST
body: {
          "amcFilter": amcFilterArr,
          "schemeTypeFilter": categoryFilterArr,
          "pledgeFilter": pledgableFilterKey,
          "orderFilter": sortOrder
        }
Parameter :   context, List amcFilterArr, List categoryFilterArr, String pledgableFilterKey, String sortOrder
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse show the SchemeMaster Details
On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/

//fetchMfMasterDetails(+)
fetchMfMasterDetails(
    {required context,
    required List amcFilterArr,
    required List categoryFilterArr,
    required String pledgableFilterKey,
    required String sortOrder}) async {
  try {
    final json = await postMethod(
        'mf/schemeMaster',
        jsonEncode({
          "amcFilter": amcFilterArr,
          "schemeTypeFilter": categoryFilterArr,
          "pledgeFilter": pledgableFilterKey,
          "orderFilter": sortOrder
        }),
        context);
    // print(json.body['mfNFOM2']);
    if (json != null && json.statusCode == 200) {
      MfSchemeMasterDetails jsonResponse =
          mfSchemeMasterDetailsFromJson(json.body);

      if (jsonResponse.status == "S") {
        return jsonResponse;
      } else if (jsonResponse.status == 'E') {
        showSnackbar(
            context,
            jsonResponse.errMsg == null ||
                    jsonResponse.errMsg.toString().isEmpty
                ? somethingError
                : jsonResponse.errMsg.toString(),
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
      throw Exception('Failed to load MFschememaster details');
    }
  } catch (e) {
    showSnackbar(context, "FMMD01F-$somethingError", Colors.red);
  }
  return null;
}
//fetchMfMasterDetails(-)

/* 
Method Name: fetchMfSchemeTypeDetails
Purpose : This API used to Get the MFSchemeType Details for show the scheme master filter details
EndPoint: mf/schemeType
API Method: POST
body: ""
Parameter : context
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse show the SchemeType Details
On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfSchemeTypeDetails(+)

fetchMfSchemeTypeDetails(
    {required context,
    required List amcFilterArr,
    required List categoryFilterArr,
    required String pledgableFilterKey,
    required String sortOrder}) async {
  try {
    final json = await postMethod(
        'mf/schemeType',
        jsonEncode({
          "amcFilter": amcFilterArr,
          "schemeTypeFilter": categoryFilterArr,
          "pledgeFilter": pledgableFilterKey,
          "orderFilter": sortOrder
        }),
        context);

    if (json != null && json.statusCode == 200) {
      Map jsonResponse = jsonDecode(json.body);
      if (jsonResponse["status"] == "S") {
        return jsonResponse;
      } else if (jsonResponse["status"] == 'E') {
        showSnackbar(
            context,
            jsonResponse["errMsg"] == null ||
                    jsonResponse["errMsg"].toString().isEmpty
                ? somethingError
                : jsonResponse["errMsg"].toString(),
            Colors.red);
      } else if (jsonResponse["status"] == 'I') {
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
    } else {
      showSnackbar(context, somethingError, Colors.red);
    }

    // else if (json == null || json.statusCode != 200) {
    //   throw Exception('Failed to load fetchMFSchemeType details');
    // }
  } catch (e) {
    showSnackbar(context, "FMSTD01F-$somethingError", Colors.red);
  }
  return null;
}
//fetchMfSchemeTypeDetails(-)

/* 
Method Name: fetchMFPurchaseConfigDetails
Purpose :This API used to Get the MFPurchaseConfigDetails Details for show the buy order bottomsheet details using isin
EndPoint: mf/purchaseConfig
API Method: POST
body: {"orderType": type, "isin": isin}
Parameter :  context,  String isin,  String type
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonResponse show the purchaseConfig Details

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMFPurchaseConfigDetails(+)
fetchMFPurchaseConfigDetails(
    {required context, required String isin, required String type}) async {
  try {
    final json = await postMethod('mf/purchaseConfig',
        jsonEncode({"orderType": type, "isin": isin}), context);
    print({"orderType": type, "isin": isin});
    print(json.body);
    if (json != null && json.statusCode == 200) {
      MFpurchaseConfigDetails jsonResponse =
          mFpurchaseConfigDetailsFromJson(json.body);

      if (jsonResponse.status == "S" || jsonResponse.status == "W") {
        return jsonResponse;
      } else if (jsonResponse.status == 'E') {
        showSnackbar(
            context,
            jsonResponse.errMsg == null ||
                    jsonResponse.errMsg.toString().isEmpty
                ? somethingError
                : jsonResponse.errMsg.toString(),
            Colors.red);
        return false;
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
      throw Exception('Failed to load MFpurchase details');
    }
  } on ClientException catch (e) {
    showSnackbar(context, "SCE02-$somethingError", Colors.red);
  } catch (e) {
    print(e.toString());
  }
  return null;
}
//fetchMFPurchaseConfigDetails(-)

//MF DashBoard Screen API's
/* 
Method Name: fetchMfHoldingDetailsAPI
Purpose :This API used to Get the mfholdingdetailsAPI Details for show the Invest Dashboard Screen details
EndPoint: mf/holdingdetails
API Method: POST
body:""
Parameter :  context
Response :
On Success:
===========
In case of a successful execution of this method, return the mfHoldingData show the holdingdetails Details

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfHoldingDetailsAPI(+)
fetchMfHoldingDetailsAPI(context) async {
  try {
    var response = await postMethod('mf/holdingdetails', "", context);

    if (response != null && response.statusCode == 200) {
      MfHoldingData mfHoldingData = mfHoldingDataFromJson(response.body);

      if (mfHoldingData.status == "S") {
        return mfHoldingData;
      } else if (mfHoldingData.status == 'E') {
        showSnackbar(
            context,
            mfHoldingData.errMsg == null ||
                    mfHoldingData.errMsg.toString().isEmpty
                ? somethingError
                : mfHoldingData.errMsg.toString(),
            Colors.red);
        return false;
      } else if (mfHoldingData.status == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, primaryRedColor);
      }
    } else {
      showSnackbar(context, somethingError, primaryRedColor);
    }
  } catch (e) {
    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}
//fetchMfHoldingDetailsAPI(-)

/* 
Method Name: fetchMfPieChartData
Purpose :This API used to Get the fetchMfPieChartData Details for show Investment Details details with pieChartData
EndPoint: mf/getPieChartData
API Method: POST
body:""
Parameter :  context
Response :
On Success:
===========
In case of a successful execution of this method, return the mFpieChartDetails show the getPieChartData Details

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/

//fetchMfPieChartData(+)
fetchMfPieChartData(context) async {
  try {
    var response = await postMethod('mf/getPieChartData', '', context);

    if (response != null && response.statusCode == 200) {
      MFpieChartDetails mFpieChartDetails =
          mFpieChartDetailsFromJson(response.body);
      if (mFpieChartDetails.status == "S") {
        return mFpieChartDetails;
      } else if (mFpieChartDetails.status == 'E') {
        showSnackbar(
            context,
            mFpieChartDetails.errMsg == null ||
                    mFpieChartDetails.errMsg.toString().isEmpty
                ? somethingError
                : mFpieChartDetails.errMsg.toString(),
            Colors.red);
        return false;
      } else if (mFpieChartDetails.status == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, primaryRedColor);
      }
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}
//fetchMfPieChartData(-)

//------------------MF Cart Screen API's----------------------

/* 
Method Name: fetchMfCartDetailsAPI
Purpose : This API used to Get the mfCartDetailsAPI Details for show the Cart Details
EndPoint: mf/cartdata
API Method: POST
body:""
Parameter :  context
Response :
On Success:
===========
In case of a successful execution of this method, return the mfCartData show the getPieChartData Details

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfCartDetailsAPI(+)

fetchMfCartDetailsAPI(context) async {
  try {
    var response = await postMethod('mf/cartdata', "", context);

    if (response != null && response.statusCode == 200) {
      MfCartData mfCartData = mfCartDataFromJson(response.body);
      if (mfCartData.status == "S") {
        return mfCartData;
      } else if (mfCartData.status == 'E') {
        showSnackbar(
            context,
            mfCartData.errMsg == null || mfCartData.errMsg.toString().isEmpty
                ? somethingError
                : mfCartData.errMsg.toString(),
            Colors.red);
        return false;
      } else if (mfCartData.status == 'I') {
        showSnackbar(context, sessionError, Colors.red);
        ChangeIndex().value = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          route.logIn,
          (route) => false,
        );
        deleteCookieInSref(context);
      } else {
        showSnackbar(context, somethingError, primaryRedColor);
      }
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    showSnackbar(context, "FMCDA01F$somethingError", primaryRedColor);
  }
  return null;
}
//fetchMfCartDetailsAPI(-)

/* 
Method Name: fetchMfCartCount
Purpose : This API used to Get the fetchMfCartCount Details for show the Cartcount Details
EndPoint: mf/cartcount
API Method: POST
body:""
Parameter :  context
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonresponse show the added cart count in bottomnavigation bar cart. 

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfCartCount(+)

fetchMfCartCount(context) async {
  try {
    final json = await postMethod('mf/cartcount', '', context);

    if (json != null && json.statusCode == 200) {
      var jsonresponse = jsonDecode(json.body);

      if (jsonresponse['status'] == "S") {
        return jsonresponse;
      } else if (jsonresponse['status'] == 'E') {
        showSnackbar(
            context,
            jsonresponse['status'] == null ||
                    jsonresponse['errMsg'].toString().isEmpty
                ? somethingError
                : jsonresponse['errMsg'].toString(),
            Colors.red);
      } else if (jsonresponse['status'] == 'I') {
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
      return null;
    }
  } catch (e) {
    showSnackbar(context, "FFCC01F-$somethingError", Colors.red);
  }
  return null;
}
//fetchMfCartCount(-)
/* 
Method Name: fetchMfCartUpdationAPI
Purpose : This API used to Post the mfCartUpdationAPI  for update the  Existing Cart Details
EndPoint: mf/cartupdation
API Method: POST
body:
//Insert Cart...
        {
          "cartStatus": "Y",
          "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
          "orderValue": double.tryParse(amount) ?? 0
        }
//Delete Cart...
    {
      "id": id,
      "cartStatus": "N",
    }

Parameter :  context
Response :
On Success:
===========
In case of a successful execution of this method,post the cart details for updating/deleting the cart, return the jsonresponse show the cartupdate Success/Error show the snack bar. 

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfCartUpdationAPI(+)

fetchMfCartUpdationAPI({required context, required Map cartDetails}) async {
  try {
    var response =
        await putMethod('mf/cartupdation', jsonEncode(cartDetails), context);
    if (response != null && response.statusCode == 200) {
      var jsonresponse = jsonDecode(response.body);

      if (jsonresponse['status'] == "S") {
        return jsonresponse;
      } else if (jsonresponse['status'] == 'E') {
        return jsonresponse;

        // showSnackbar(
        //     context,
        //     jsonresponse['errMsg'].toString().isEmpty
        //         ? somethingError
        //         : jsonresponse['errMsg'].toString(),
        //     Colors.red);
      } else if (jsonresponse['status'] == 'I') {
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
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    print(e);

    // showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}
//fetchMfCartUpdationAPI(-)

//Transaction Screen......

/* 
Method Name: fetchMfTransactionDetailsAPI
Purpose :This API used to Get the mfTrasnactionDetailsAPI Details show the Transaction Screen 
EndPoint: mf/transactiondata
API Method: POST
body:{
            "fromdate": previousMonth.toString().split(' ')[0],
            "todate": now.toString().split(' ')[0],
            "rangetype": 'Y'
          }
Parameter :  context,transactionDetails
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonresponse show the Transaction Details in API. 

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/

//fetchMfTransactionDetailsAPI(+)

fetchMfTransactionDetailsAPI({context, required Map transactionDetails}) async {
  try {
    var response = await postMethod(
        'mf/transactiondata', jsonEncode(transactionDetails), context);

    if (response != null && response.statusCode == 200) {
      MfTransactionData mfTransactionData =
          mfTransactionDataFromJson(response.body);
      if (mfTransactionData.status == "S") {
        return mfTransactionData;
      } else if (mfTransactionData.status == 'E') {
        showSnackbar(
            context,
            mfTransactionData.errMsg.toString().isEmpty
                ? somethingError
                : mfTransactionData.errMsg.toString(),
            Colors.red);
      } else if (mfTransactionData.status == 'I') {
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
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}

//fetchMfTransactionDetailsAPI(-)

/* 
Method Name: fetchMfTransStatusDetailsAPI
Purpose :This API used to Get the mfTrasnactionStatusDetailsAPI Details show the Transaction bottom Sheet 
EndPoint: mf/transactionstatusdata
API Method: POST
body:
         {
            "transNo": widget.mfTransactionDatum.transNo
          }
Parameter :  context,transactionstatusDetails
Response :
On Success:
===========
In case of a successful execution of this method, return the jsonresponse show the TransactionStatus Details timeline in API. 

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//fetchMfTransStatusDetailsAPI(+)

fetchMfTransStatusDetailsAPI(
    {context, required Map transactionstatusDetails}) async {
  try {
    var response = await postMethod('mf/transactionstatusdata',
        jsonEncode(transactionstatusDetails), context);
    print(response.body);

    if (response != null && response.statusCode == 200) {
      MfTransactionStatusDetails mfTransactionStatusDetails =
          mfTransactionStatusDetailsFromJson(response.body);
      if (mfTransactionStatusDetails.status == "S") {
        return mfTransactionStatusDetails;
      } else if (mfTransactionStatusDetails.status == 'E') {
        showSnackbar(
            context,
            mfTransactionStatusDetails.errMsg.toString().isEmpty
                ? somethingError
                : mfTransactionStatusDetails.errMsg.toString(),
            Colors.red);
      } else if (mfTransactionStatusDetails.status == 'I') {
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
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}
//fetchMfTransStatusDetailsAPI(-)
/* 
Method Name: postPurchaseOrderAPI
Purpose :This API's is Purchase the API all purchase/redeem this api used on the purchase
EndPoint: mf/purchase
API Method: POST
body:
        {
            "isin": purchaseConfigDetails?.mfSchemeMaster?.isin ?? "",
            "OrderVal": double.tryParse(amountController.text) ?? 0,
            "BuySell": "P" (or) "R",  // P=purchase, R=Redeeem
            "BuySellType": "FRESH",
            "Qty": 0,
            "navValue": double.tryParse(navController.text) ?? 0,
          }
Parameter :  context,purchaseDetails
Response :
On Success:
===========
In case of a successful execution of this method, post the purchaseDetails and show the response on Dialogbox. 

On Error:
===========
In case of any exception during the execution of this method you will get the
error details. the calling program should handle the error and Show The Snackbar.

Author : SRI PARAMASIVAM A
Date : 17-Aug-2024

*/
//postPurchaseOrderAPI(+)

postPurchaseOrderAPI({context, required Map purchaseDetails}) async {
  try {
    var response =
        await postMethod('mf/purchase', jsonEncode(purchaseDetails), context);

    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    showSnackbar(context, "SPOA01$somethingError", primaryRedColor);
  }
  return null;
}
//postPurchaseOrderAPI(-)

//Currently Bulk cart purchase is Not Eligible for MF..
//This API is purshase the cart purchase for existing buy......

mfbuyAllCartDataAPI({required context, required Map cartDetails}) async {
  try {
    var response =
        await putMethod('mf/mfCartPurchase', jsonEncode(cartDetails), context);
    if (response != null && response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json["status"] == "S") {
        return json;
      } else {
        showSnackbar(context, "error Busy...", primaryRedColor);
      }
    } else {
      showSnackbar(context, "Server Busy...", primaryRedColor);
    }
  } catch (e) {
    // print(e);
  }

  return null;
}

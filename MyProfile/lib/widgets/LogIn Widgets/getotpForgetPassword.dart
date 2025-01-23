import 'package:flutter/material.dart';
import 'package:novo/API/APICall.dart';
import 'package:novo/utils/colors.dart';
import '../NOVO Widgets/LoadingAlertBox.dart';
import '../NOVO Widgets/snackbar.dart';
import '../NOVO Widgets/textFieldWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';

getOtp(context) {
  TextEditingController getoptuseridcontroller = TextEditingController();
  TextEditingController getoptpancontroller = TextEditingController();
  var formKey = GlobalKey<FormState>();
  getOtpPost() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    loadingAlertBox(context, 'Sending OTP...');
    var getoptresponse = await postGetOtpDetails(
        context: context,
        panno: getoptpancontroller.text.toUpperCase(),
        userId: getoptuseridcontroller.text.toUpperCase());

    Navigator.of(context).pop();
    if (getoptresponse == true) {
      showSnackbar(context, 'OTP sent successfully', primaryGreenColor);
      Navigator.of(context).pop();
    } else {
      // showSnackbar(context, getoptresponse, primaryRedColor);
      Fluttertoast.showToast(
          msg: getoptresponse,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
            titlePadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            actions: [
              MaterialButton(
                elevation: 2,
                minWidth: 100,
                height: 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: appPrimeColor,
                onPressed: () {
                  getOtpPost();
                },
                child: const Text(
                  "SEND OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w700,
                    // height: 1.04,
                  ),
                ),
              ),
            ],
            title: Container(
              color: inactiveColor,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close)),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text('GET OTP',
                      style: TextStyle(
                          fontSize: titleFontSize, fontFamily: 'inter'))
                ],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            content: Container(
              padding: const EdgeInsets.all(15.0),

              // height: MediaQuery.of(context).size.height * 0.23,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NameField(
                      userIdController: getoptuseridcontroller,
                      labelname: "User ID",
                      readOnly: false,
                    ),
                    const SizedBox(height: 20),
                    /* pancard Or dateofbirth validation */

                    PanCardField(
                      panController: getoptpancontroller,
                      labelname: "PAN",
                    ),
                  ],
                ),
              ),
            )),
      );
    },
  );
}

forgetPassword(context) {
  TextEditingController forgetPasswordUserId = TextEditingController();
  TextEditingController forgetPasswordPan = TextEditingController();
  TextEditingController forgetPasswordDOB = TextEditingController();
  var formKey = GlobalKey<FormState>();

  resetPasswordpost() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    loadingAlertBox(context, 'Password Resetting...');

    var getoptresponse = await postForgetOtpDetails(
        context: context,
        panno: forgetPasswordPan.text.toUpperCase(),
        userId: forgetPasswordUserId.text.toUpperCase(),
        dob: forgetPasswordDOB.text);
    Navigator.of(context).pop();
    if (getoptresponse == true) {
      Navigator.of(context).pop();
      showSnackbar(context, 'Password Reset successfully', primaryGreenColor);
    } else {
      // showSnackbar(context, 'Something went wrong', primaryRedColor);
      Fluttertoast.showToast(
          msg: getoptresponse,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
            titlePadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            actions: [
              MaterialButton(
                elevation: 2,
                minWidth: 100,
                height: 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: appPrimeColor,
                onPressed: () {
                  resetPasswordpost();
                },
                child: const Text(
                  "RESET",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w700,
                    // height: 1.04,
                  ),
                ),
              ),
            ],
            title: Container(
              color: inactiveColor,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close)),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    'FORGOT PASSWORD',
                    style:
                        TextStyle(fontSize: titleFontSize, fontFamily: 'inter'),
                  )
                ],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            content: Container(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NameField(
                      userIdController: forgetPasswordUserId,
                      labelname: "User ID",
                      readOnly: false,
                    ),
                    const SizedBox(height: 10),
                    /* pancard Or dateofbirth validation */

                    PanCardField(
                      panController: forgetPasswordPan,
                      labelname: "PAN",
                    ),
                    const SizedBox(height: 10),
                    /* pancard Or dateofbirth validation */

                    DobField(
                      dobController: forgetPasswordDOB,
                      labelname: "DOB [DDMMYYYY]",
                      hindtext: "eg.01122000",
                    ),
                  ],
                ),
              ),
            )),
      );
    },
  );
}
